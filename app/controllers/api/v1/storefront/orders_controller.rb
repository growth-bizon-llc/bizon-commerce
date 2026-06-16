module Api
  module V1
    module Storefront
      class OrdersController < BaseController
        before_action :ensure_cart, only: [:create]
        before_action :authenticate_customer_or_session!, only: [:show]

        def create
          service = Orders::CreateFromCartService.new(
            cart: @cart,
            email: params[:email],
            customer: current_customer,
            shipping_address: params[:shipping_address]&.permit(:first_name, :last_name, :company, :address1, :address2, :city, :state, :zip, :postal_code, :country, :phone)&.to_h || {},
            billing_address: params[:billing_address]&.permit(:first_name, :last_name, :company, :address1, :address2, :city, :state, :zip, :postal_code, :country, :phone)&.to_h || {},
            notes: params[:notes]
          )
          service.call

          if service.success?
            render json: StorefrontOrderSerializer.new(service.result).to_h, status: :created
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        def accept_terms
          order = Order.find_by!(order_number: "##{params[:order_number]}", store: Current.store)
          order.update!(terms_accepted: true, terms_accepted_at: Time.current)
          render json: { accepted: true }
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Order not found" }, status: :not_found
        end

        def show
          order = if current_customer
                    Order.where(store: Current.store, customer: current_customer)
                         .find_by!(order_number: "##{params[:order_number]}")
                  elsif params[:session_id].present?
                    Order.where(store: Current.store, stripe_session_id: params[:session_id])
                         .find_by!(order_number: "##{params[:order_number]}")
                  else
                    raise ActiveRecord::RecordNotFound
                  end
          render json: StorefrontOrderSerializer.new(order).to_h
        end

        private

        def authenticate_customer_or_session!
          return if current_customer
          return if params[:session_id].present?

          render json: { error: "Customer authentication required" }, status: :unauthorized
        end

        def ensure_cart
          token = request.headers["X-Cart-Token"] || params[:cart_token]
          @cart = Cart.where(store: Current.store).find_by!(token: token, status: 'active')
        end
      end
    end
  end
end
