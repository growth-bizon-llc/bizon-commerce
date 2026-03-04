module Api
  module V1
    module Storefront
      class ProductsController < BaseController
        def index
          products = Product.active.includes(:category, :variants, :product_images).ordered
          products = products.where(category_id: params[:category_id]) if params[:category_id].present?
          products = products.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
          products = products.featured if params[:featured] == 'true'
          products = products.in_stock if params[:in_stock] == 'true'

          pagy, records = pagy(products)
          render json: {
            products: ProductListSerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end

        def show
          product = Product.active.friendly.find(params[:slug])
          render json: ProductSerializer.new(product).to_h
        end
      end
    end
  end
end
