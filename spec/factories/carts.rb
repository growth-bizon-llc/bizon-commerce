FactoryBot.define do
  factory :cart do
    store
    customer { nil }
    token { SecureRandom.urlsafe_base64(32) }
    status { 'active' }
    metadata { {} }

    trait :with_customer do
      customer
    end

    trait :with_items do
      after(:create) do |cart|
        product = create(:product, :active, store: cart.store)
        create(:cart_item, cart: cart, product: product, unit_price_cents: product.base_price_cents)
      end
    end

    trait :converted do
      status { 'converted' }
    end

    trait :abandoned do
      status { 'abandoned' }
    end
  end
end
