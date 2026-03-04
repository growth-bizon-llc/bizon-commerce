module Api
  module V1
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: [:show, :update, :destroy]

        def index
          products = policy_scope(Product).includes(:category, :variants, :product_images).ordered
          products = products.where(status: params[:status]) if params[:status].present?
          products = products.where(category_id: params[:category_id]) if params[:category_id].present?
          products = products.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
          products = products.featured if params[:featured] == 'true'

          pagy, records = pagy(products, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: {
            products: ProductListSerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end

        def show
          authorize @product
          render json: ProductSerializer.new(@product).to_h
        end

        def create
          product = Product.new(product_params)
          product.store = Current.store
          authorize product
          product.save!
          render json: ProductSerializer.new(product).to_h, status: :created
        end

        def update
          authorize @product
          @product.update!(product_params)
          render json: ProductSerializer.new(@product.reload).to_h
        end

        def destroy
          authorize @product
          @product.discard!
          head :no_content
        end

        private

        def set_product
          @product = Product.find(params[:id])
        end

        def product_params
          params.require(:product).permit(
            :name, :description, :short_description, :category_id,
            :base_price_cents, :base_price_currency,
            :compare_at_price_cents, :compare_at_price_currency,
            :sku, :barcode, :track_inventory, :quantity,
            :status, :featured, :position, :published_at,
            custom_attributes: {}
          )
        end
      end
    end
  end
end
