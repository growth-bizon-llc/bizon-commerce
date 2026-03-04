module Api
  module V1
    module Storefront
      class SessionsController < BaseController
        def create
          customer = Customer.find_by(email: params[:email])

          if customer&.authenticate(params[:password])
            token = generate_customer_token(customer)
            render json: {
              customer: CustomerSerializer.new(customer).to_h,
              token: token
            }
          else
            render json: { error: "Invalid email or password" }, status: :unauthorized
          end
        end

        private

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
