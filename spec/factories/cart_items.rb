FactoryBot.define do
  factory :cart_item do
    cart
    product
    product_variant { nil }
    quantity { 1 }
    unit_price_cents { 1000 }
    unit_price_currency { 'USD' }
  end
end
