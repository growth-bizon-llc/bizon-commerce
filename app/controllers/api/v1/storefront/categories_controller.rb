module Api
  module V1
    module Storefront
      class CategoriesController < BaseController
        def index
          categories = Category.active.root.ordered.includes(:children)
          pagy, records = pagy(categories, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: { categories: CategorySerializer.new(records).serializable_hash, meta: pagination_meta(pagy) }
        end

        def show
          category = Category.active.friendly.find(params[:slug])
          products = category.products.active.ordered
          pagy, records = pagy(products)

          render json: {
            category: CategorySerializer.new(category).to_h,
            products: ProductListSerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end
      end
    end
  end
end
