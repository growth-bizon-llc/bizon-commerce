module Api
  module V1
    module Storefront
      class CustomersController < BaseController
        before_action :authenticate_customer!, only: [:show, :destroy, :export_data]

        def create
          customer = Customer.new(customer_params)
          customer.store = Current.store
          customer.save!

          token = generate_customer_token(customer)
          render json: {
            customer: CustomerSerializer.new(customer).to_h,
            token: token
          }, status: :created
        end

        def show
          render json: { customer: CustomerSerializer.new(current_customer).to_h }
        end

        def destroy
          customer = current_customer

          if customer.orders.where(status: %w[processing shipped]).exists?
            return render json: { error: "Cannot delete account with active orders" }, status: :unprocessable_entity
          end

          customer.carts.destroy_all
          customer.orders.where(status: %w[pending confirmed]).find_each { |o| o.cancel! if o.may_cancel? }

          # Anonymize PII in all orders
          anonymized_address = { 'first_name' => 'Redacted', 'last_name' => 'Redacted', 'street' => 'Redacted', 'city' => 'Redacted', 'state' => 'Redacted', 'country' => 'Redacted' }
          anon_hash = Digest::SHA256.hexdigest(customer.id.to_s)[0..7]
          customer.orders.find_each do |order|
            order.update_columns(
              email: "deleted-#{anon_hash}@deleted.local",
              shipping_address: anonymized_address,
              billing_address: anonymized_address,
              notes: nil,
              metadata: {}
            )
          end

          customer.update!(
            email: "deleted-#{anon_hash}@deleted.local",
            first_name: "Deleted",
            last_name: "User",
            phone: nil,
            metadata: {},
            password_digest: "deleted",
            deleted_at: Time.current
          )

          render json: { message: "Account data has been deleted" }
        end

        def export_data
          customer = current_customer
          data = {
            personal_info: {
              email: customer.email,
              first_name: customer.first_name,
              last_name: customer.last_name,
              phone: customer.phone,
              accepts_marketing: customer.accepts_marketing,
              created_at: customer.created_at,
              updated_at: customer.updated_at
            },
            orders: customer.orders.includes(:order_items).map do |order|
              {
                order_number: order.order_number,
                status: order.status,
                payment_status: order.payment_status,
                email: order.email,
                total: order.total_cents,
                placed_at: order.placed_at,
                shipping_address: order.shipping_address,
                billing_address: order.billing_address,
                items: order.order_items.map do |item|
                  { product_name: item.product_name, quantity: item.quantity, total: item.total_cents }
                end
              }
            end
          }

          render json: data
        end

        private

        def customer_params
          params.require(:customer).permit(:email, :first_name, :last_name, :phone, :password, :password_confirmation, :accepts_marketing)
        end

        def generate_customer_token(customer)
          JWT.encode(
            { customer_id: customer.id, exp: 24.hours.from_now.to_i },
            Rails.application.secret_key_base,
            'HS256'
          )
        end
      end
    end
  end
end
