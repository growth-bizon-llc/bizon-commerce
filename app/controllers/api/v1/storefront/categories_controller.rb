module Api
  module V1
    module Storefront
      class CategoriesController < BaseController
        def index
          categories = Category.active.root.ordered.order(:id).includes(:children)
          pagy, records = pagy(categories, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: { categories: CategorySerializer.new(records).serializable_hash, meta: pagination_meta(pagy) }
        end

        def show
          category = Category.active.friendly.find(params[:slug])
          category_ids = [category.id] + category.children.active.pluck(:id)
          products = Product.active.where(category_id: category_ids).includes(:category, :product_images, :variants).ordered.order(:id)
          pagy, records = pagy(products, limit: (params[:per_page] || 20).to_i.clamp(1, 100))

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
