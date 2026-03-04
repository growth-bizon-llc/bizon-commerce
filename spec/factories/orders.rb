FactoryBot.define do
  factory :order do
    store
    customer { nil }
    sequence(:order_number) { |n| "##{1000 + n}" }
    email { Faker::Internet.email }
    status { 'pending' }
    subtotal_cents { 5000 }
    subtotal_currency { 'USD' }
    tax_cents { 400 }
    tax_currency { 'USD' }
    total_cents { 5400 }
    total_currency { 'USD' }
    shipping_address { { line1: '123 Main St', city: 'NY', state: 'NY', zip: '10001' } }
    billing_address { { line1: '123 Main St', city: 'NY', state: 'NY', zip: '10001' } }
    placed_at { Time.current }

    trait :with_customer do
      customer
    end

    trait :confirmed do
      status { 'confirmed' }
    end

    trait :paid do
      status { 'paid' }
      paid_at { Time.current }
    end

    trait :processing do
      status { 'processing' }
      paid_at { 1.day.ago }
    end

    trait :shipped do
      status { 'shipped' }
      paid_at { 3.days.ago }
      shipped_at { Time.current }
    end

    trait :delivered do
      status { 'delivered' }
      paid_at { 5.days.ago }
      shipped_at { 3.days.ago }
      delivered_at { Time.current }
    end

    trait :cancelled do
      status { 'cancelled' }
      cancelled_at { Time.current }
    end

    trait :with_items do
      after(:create) do |order|
        product = create(:product, :active, store: order.store)
        create(:order_item, order: order, product: product)
      end
    end
  end
end
