module Products
  class CreateWithVariantsService < BaseService
    def initialize(store:, product_params:, variants_params: [], images: [])
      super()
      @store = store
      @product_params = product_params
      @variants_params = variants_params
      @images = images
    end

    def call
      ActiveRecord::Base.transaction do
        @result = create_product
        create_variants if @variants_params.any?
        attach_images if @images.any?
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      self
    end

    private

    def create_product
      Product.create!(@product_params.merge(store: @store))
    end

    def create_variants
      @variants_params.each_with_index do |variant_params, index|
        @result.variants.create!(
          variant_params.merge(store: @store, position: index)
        )
      end
    end

    def attach_images
      @images.each_with_index do |image, index|
        product_image = @result.product_images.create!(
          store: @store,
          position: index,
          alt_text: image[:alt_text]
        )
        product_image.image.attach(image[:file]) if image[:file]
      end
    end
  end
end
