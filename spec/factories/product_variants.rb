FactoryBot.define do
  factory :product_variant do
    store
    product
    name { "#{Faker::Color.color_name} / #{%w[S M L XL].sample}" }
    sku { "VAR-#{SecureRandom.hex(4).upcase}" }
    price_cents { rand(1000..50000) }
    price_currency { 'USD' }
    track_inventory { true }
    quantity { 10 }
    options { { color: Faker::Color.color_name, size: %w[S M L XL].sample } }
    position { 0 }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :out_of_stock do
      quantity { 0 }
    end
  end
end
