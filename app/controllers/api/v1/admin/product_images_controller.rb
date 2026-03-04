module Api
  module V1
    module Admin
      class ProductImagesController < BaseController
        before_action :set_product
        before_action :set_image, only: [:update, :destroy]

        def index
          images = policy_scope(@product.product_images).ordered
          render json: { images: ProductImageSerializer.new(images).serializable_hash }
        end

        def create
          unless params[:image].is_a?(ActionDispatch::Http::UploadedFile)
            return render json: { error: "Image file is required" }, status: :unprocessable_entity
          end

          image = @product.product_images.new(image_params)
          image.store = Current.store
          authorize image, policy_class: ProductImagePolicy
          image.image.attach(params[:image])
          image.save!
          render json: ProductImageSerializer.new(image).to_h, status: :created
        end

        def update
          authorize @image, policy_class: ProductImagePolicy
          @image.update!(image_params)
          render json: ProductImageSerializer.new(@image).to_h
        end

        def destroy
          authorize @image, policy_class: ProductImagePolicy
          @image.destroy!
          head :no_content
        end

        private

        def set_product
          @product = Product.find(params[:product_id])
        end

        def set_image
          @image = @product.product_images.find(params[:id])
        end

        def image_params
          params.permit(:position, :alt_text)
        end
      end
    end
  end
end
