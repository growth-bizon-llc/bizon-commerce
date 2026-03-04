FactoryBot.define do
  factory :order_item do
    order
    product
    product_variant { nil }
    product_name { Faker::Commerce.product_name }
    variant_name { nil }
    sku { "SKU-#{SecureRandom.hex(3).upcase}" }
    quantity { 1 }
    unit_price_cents { 2500 }
    unit_price_currency { 'USD' }
    total_cents { 2500 }
    total_currency { 'USD' }
  end
end
