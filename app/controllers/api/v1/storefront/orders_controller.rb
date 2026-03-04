module Api
  module V1
    module Storefront
      class OrdersController < BaseController
        before_action :ensure_cart, only: [:create]

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
            render json: OrderSerializer.new(service.result).to_h, status: :created
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        def show
          order = Order.where(store: Current.store).find_by!(order_number: "##{params[:order_number]}")
          render json: OrderSerializer.new(order).to_h
        end

        private

        def ensure_cart
          token = request.headers["X-Cart-Token"] || params[:cart_token]
          @cart = Cart.where(store: Current.store).find_by!(token: token, status: 'active')
        end
      end
    end
  end
end
