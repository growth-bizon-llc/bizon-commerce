FactoryBot.define do
  factory :user do
    store
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { :staff }
    jti { SecureRandom.uuid }

    trait :staff do
      role { :staff }
    end

    trait :admin do
      role { :admin }
    end

    trait :owner do
      role { :owner }
    end
  end
end
