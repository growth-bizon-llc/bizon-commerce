FactoryBot.define do
  factory :product_image do
    store
    product
    position { 0 }
    alt_text { Faker::Lorem.sentence }

    after(:build) do |image|
      image.image.attach(
        io: StringIO.new('fake image data'),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
