FactoryBot.define do
  factory :product_image do
    store
    product
    position { 0 }
    alt_text { Faker::Lorem.sentence }
  end
end
