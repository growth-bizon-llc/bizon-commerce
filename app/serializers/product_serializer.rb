class ProductSerializer
  include Alba::Resource

  attributes :id, :name, :slug, :description, :short_description,
             :sku, :barcode, :status, :featured, :custom_attributes,
             :quantity, :track_inventory, :position, :published_at,
             :created_at, :updated_at

  attribute :base_price do |product|
    { amount: product.base_price.to_f, currency: product.base_price_currency }
  end

  attribute :compare_at_price do |product|
    next nil unless product.compare_at_price_cents
    { amount: product.compare_at_price.to_f, currency: product.compare_at_price_currency }
  end

  has_one :category, serializer: CategoryListSerializer
  has_many :variants, serializer: VariantSerializer
  has_many :product_images, key: :images, serializer: ProductImageSerializer
end
