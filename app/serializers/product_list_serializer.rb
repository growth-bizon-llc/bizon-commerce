class ProductListSerializer
  include Alba::Resource

  attributes :id, :name, :slug, :short_description, :sku,
             :status, :featured, :quantity, :track_inventory,
             :position, :created_at

  attribute :base_price do |product|
    { amount: product.base_price.to_f, currency: product.base_price_currency }
  end

  attribute :compare_at_price do |product|
    next nil unless product.compare_at_price_cents
    { amount: product.compare_at_price.to_f, currency: product.compare_at_price_currency }
  end

  attribute :category_name do |product|
    product.category&.name
  end

  attribute :variants_count do |product|
    product.variants.size
  end
end
