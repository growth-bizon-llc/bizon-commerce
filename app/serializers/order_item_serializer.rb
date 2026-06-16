class OrderItemSerializer
  include Alba::Resource

  attributes :id, :product_id, :product_variant_id,
             :product_name, :variant_name, :sku, :quantity

  attribute :unit_price do |item|
    { amount: item.unit_price.to_f, currency: item.unit_price_currency }
  end

  attribute :total do |item|
    { amount: item.total.to_f, currency: item.total_currency }
  end

  attribute :primary_image_url do |item|
    item.product&.product_images&.ordered&.first&.image_url
  end
end
