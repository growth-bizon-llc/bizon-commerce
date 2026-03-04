FactoryBot.define do
  factory :customer do
    store
    sequence(:email) { |n| "customer#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    password { 'password123' }
    password_confirmation { 'password123' }
    accepts_marketing { false }
    metadata { {} }
  end
end
