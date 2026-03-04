module Api
  module V1
    module Storefront
      class CustomersController < BaseController
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

        private

        def customer_params
          params.require(:customer).permit(:email, :first_name, :last_name, :phone, :password, :password_confirmation)
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
