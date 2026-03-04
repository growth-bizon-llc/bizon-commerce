FactoryBot.define do
  factory :store do
    name { Faker::Company.name }
    sequence(:slug) { |n| "store-#{n}" }
    sequence(:custom_domain) { |n| "store#{n}.example.com" }
    sequence(:subdomain) { |n| "store#{n}" }
    description { Faker::Lorem.paragraph }
    currency { 'USD' }
    locale { 'en' }
    settings { {} }
    active { true }
  end
end
