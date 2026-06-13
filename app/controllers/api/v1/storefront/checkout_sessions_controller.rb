module Api
  module V1
    module Storefront
      class CheckoutSessionsController < BaseController
        before_action :ensure_cart, only: [:create]

        def create
          service = Orders::CreateFromCartService.new(
            cart: @cart,
            email: params[:email],
            customer: current_customer,
            shipping_address: extract_address(params[:shipping_address]),
            billing_address: extract_address(params[:billing_address]),
            notes: params[:notes]
          )
          service.call

          unless service.success?
            return render json: { errors: service.errors }, status: :unprocessable_entity
          end

          order = service.result

          begin
            checkout_session = create_stripe_session(order)
          rescue Stripe::StripeError => e
            order.cancel! if order.may_cancel?
            order.save!
            return render json: { errors: ["Payment service unavailable: #{e.message}"] }, status: :service_unavailable
          end

          order.update!(stripe_session_id: checkout_session.id)

          render json: {
            client_secret: checkout_session.client_secret,
            order_number: order.order_number
          }, status: :created
        end

        def status
          order = Order.find_by!(stripe_session_id: params[:id], store: Current.store)
          checkout_session = Stripe::Checkout::Session.retrieve(params[:id])

          render json: {
            status: checkout_session.status,
            payment_status: checkout_session.payment_status,
            customer_email: checkout_session.customer_details&.email
          }
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Session not found" }, status: :not_found
        end

        private

        def ensure_cart
          token = request.headers["X-Cart-Token"] || params[:cart_token]
          @cart = Cart.where(store: Current.store).lock.find_by!(token: token, status: 'active')
        end

        def extract_address(addr)
          return {} if addr.blank?

          allowed = %w[first_name last_name company address1 address2 city state zip postal_code country phone street]
          case addr
          when ActionController::Parameters
            addr.permit(*allowed).to_h
          when Hash
            addr.slice(*allowed)
          else
            {}
          end
        end

        def safe_return_url
          default_url = "#{request.base_url}/checkout/complete?session_id={CHECKOUT_SESSION_ID}"
          return default_url unless params[:return_url].present?

          uri = URI.parse(params[:return_url])
          return default_url unless uri.host == request.host || uri.host.nil?

          params[:return_url]
        rescue URI::InvalidURIError
          default_url
        end

        def create_stripe_session(order)
          line_items = order.order_items.includes(:product).map do |item|
            item_data = {
              price_data: {
                currency: item.unit_price_currency.downcase,
                product_data: {
                  name: item.product_name
                },
                unit_amount: item.unit_price_cents
              },
              quantity: item.quantity
            }

            item_data
          end

          # Add tax as a separate line item if present
          if order.tax_cents > 0
            line_items << {
              price_data: {
                currency: order.tax_currency.downcase,
                product_data: { name: 'Tax' },
                unit_amount: order.tax_cents
              },
              quantity: 1
            }
          end

          Stripe::Checkout::Session.create(
            {
              ui_mode: 'embedded',
              mode: 'payment',
              line_items: line_items,
              customer_email: order.email,
              metadata: {
                order_id: order.id,
                store_id: Current.store.id
              },
              return_url: safe_return_url
            },
            { idempotency_key: "checkout_#{order.id}" }
          )
        end
      end
    end
  end
end
