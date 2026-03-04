module Api
  module V1
    module Admin
      class CategoriesController < BaseController
        before_action :set_category, only: [:show, :update, :destroy]

        def index
          categories = policy_scope(Category).ordered
          pagy, records = pagy(categories, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: {
            categories: CategorySerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end

        def show
          authorize @category
          render json: CategorySerializer.new(@category).to_h
        end

        def create
          category = Category.new(category_params)
          category.store = Current.store
          authorize category
          category.save!
          render json: CategorySerializer.new(category).to_h, status: :created
        end

        def update
          authorize @category
          @category.update!(category_params)
          render json: CategorySerializer.new(@category).to_h
        end

        def destroy
          authorize @category
          @category.discard!
          head :no_content
        end

        private

        def set_category
          @category = Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :description, :parent_id, :position, :active)
        end
      end
    end
  end
end
