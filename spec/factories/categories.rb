FactoryBot.define do
  factory :category do
    store
    name { Faker::Commerce.department(max: 1) }
    sequence(:slug) { |n| "category-#{n}" }
    description { Faker::Lorem.paragraph }
    position { 0 }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :with_parent do
      parent { association :category, store: store }
    end
  end
end
