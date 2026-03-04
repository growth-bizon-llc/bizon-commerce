module Api
  module V1
    module Admin
      class VariantsController < BaseController
        before_action :set_product
        before_action :set_variant, only: [:show, :update, :destroy]

        def index
          variants = policy_scope(@product.variants).ordered
          render json: { variants: VariantSerializer.new(variants).serializable_hash }
        end

        def show
          authorize @variant, policy_class: ProductPolicy
          render json: VariantSerializer.new(@variant).to_h
        end

        def create
          variant = @product.variants.new(variant_params)
          variant.store = Current.store
          authorize variant, policy_class: ProductPolicy
          variant.save!
          render json: VariantSerializer.new(variant).to_h, status: :created
        end

        def update
          authorize @variant, policy_class: ProductPolicy
          @variant.update!(variant_params)
          render json: VariantSerializer.new(@variant).to_h
        end

        def destroy
          authorize @variant, policy_class: ProductPolicy
          @variant.discard!
          head :no_content
        end

        private

        def set_product
          @product = Product.find(params[:product_id])
        end

        def set_variant
          @variant = @product.variants.find(params[:id])
        end

        def variant_params
          params.require(:variant).permit(
            :name, :sku, :price_cents, :price_currency,
            :compare_at_price_cents, :compare_at_price_currency,
            :track_inventory, :quantity, :position, :active,
            options: {}
          )
        end
      end
    end
  end
end
