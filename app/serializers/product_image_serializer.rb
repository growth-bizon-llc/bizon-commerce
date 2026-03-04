class ProductImageSerializer
  include Alba::Resource

  attributes :id, :position, :alt_text, :created_at, :updated_at

  attribute :url do |image|
    image.image_url
  end
end
