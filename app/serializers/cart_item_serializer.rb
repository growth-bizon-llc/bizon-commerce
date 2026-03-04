class CartItemSerializer
  include Alba::Resource

  attributes :id, :quantity, :created_at, :updated_at

  attribute :unit_price do |item|
    { amount: item.unit_price_cents / 100.0, currency: item.unit_price_currency }
  end

  attribute :total do |item|
    { amount: item.total / 100.0, currency: item.unit_price_currency }
  end

  attribute :product do |item|
    { id: item.product_id, name: item.product.name, slug: item.product.slug }
  end

  attribute :variant do |item|
    next nil unless item.product_variant
    { id: item.product_variant_id, name: item.product_variant.name }
  end
end
