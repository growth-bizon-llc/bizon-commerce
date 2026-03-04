class VariantSerializer
  include Alba::Resource

  attributes :id, :name, :sku, :track_inventory, :quantity,
             :options, :position, :active, :created_at, :updated_at

  attribute :price do |variant|
    { amount: variant.price.to_f, currency: variant.price_currency }
  end

  attribute :compare_at_price do |variant|
    next nil unless variant.compare_at_price_cents
    { amount: variant.compare_at_price.to_f, currency: variant.compare_at_price_currency }
  end
end
