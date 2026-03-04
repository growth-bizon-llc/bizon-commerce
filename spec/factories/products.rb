FactoryBot.define do
  factory :product do
    store
    category
    name { Faker::Commerce.product_name }
    sequence(:slug) { |n| "product-#{n}" }
    description { Faker::Lorem.paragraph }
    short_description { Faker::Lorem.sentence }
    base_price_cents { rand(1000..50000) }
    base_price_currency { 'USD' }
    sku { "SKU-#{SecureRandom.hex(4).upcase}" }
    track_inventory { true }
    quantity { 10 }
    status { 'draft' }
    featured { false }
    position { 0 }

    trait :active do
      status { 'active' }
      published_at { Time.current }
    end

    trait :archived do
      status { 'archived' }
    end

    trait :featured do
      featured { true }
    end

    trait :out_of_stock do
      quantity { 0 }
    end

    trait :with_variants do
      after(:create) do |product|
        create_list(:product_variant, 2, product: product, store: product.store)
      end
    end

    trait :with_compare_price do
      compare_at_price_cents { 99999 }
      compare_at_price_currency { 'USD' }
    end
  end
end
