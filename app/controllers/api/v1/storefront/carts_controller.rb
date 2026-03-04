module Api
  module V1
    module Storefront
      class CartsController < BaseController
        before_action :ensure_cart, only: [:show, :add_item, :update_item, :remove_item, :clear]

        def show
          render json: CartSerializer.new(@cart).to_h
        end

        def add_item
          product = Product.active.find(params[:product_id])
          variant = params[:variant_id] ? ProductVariant.active.find(params[:variant_id]) : nil

          if variant && variant.product_id != product.id
            return render json: { error: "Variant does not belong to this product" }, status: :unprocessable_entity
          end

          service = Carts::AddItemService.new(
            cart: @cart,
            product: product,
            variant: variant,
            quantity: params[:quantity] || 1
          )
          service.call

          if service.success?
            render json: CartSerializer.new(@cart.reload).to_h
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        def update_item
          service = Carts::UpdateItemService.new(
            cart: @cart,
            cart_item_id: params[:cart_item_id],
            quantity: params[:quantity]
          )
          service.call

          if service.success?
            render json: CartSerializer.new(@cart.reload).to_h
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        def remove_item
          service = Carts::RemoveItemService.new(
            cart: @cart,
            cart_item_id: params[:cart_item_id]
          )
          service.call

          if service.success?
            render json: CartSerializer.new(@cart.reload).to_h
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        def clear
          @cart.clear!
          render json: CartSerializer.new(@cart.reload).to_h
        end

        private

        def ensure_cart
          token = request.headers["X-Cart-Token"] || params[:cart_token]
          @cart = Cart.where(store: Current.store).find_by(token: token, status: 'active') if token
          @cart ||= Cart.create!(store: Current.store, customer: current_customer)

          response.set_header('X-Cart-Token', @cart.token)
        end
      end
    end
  end
end
