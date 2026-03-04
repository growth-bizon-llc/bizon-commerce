require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:product) }
  end

  describe '#image_url' do
    it 'returns nil when no image attached' do
      product = create(:product, store: store)
      image = ProductImage.new(product: product, store: store)
      expect(image.image_url).to be_nil
    end

    it 'returns url when image is attached' do
      product = create(:product, store: store)
      image = create(:product_image, product: product, store: store)
      image.image.attach(
        io: StringIO.new('fake image data'),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      expect(image.image_url).to be_present
      expect(image.image_url).to include('test.jpg')
    end
  end

  describe 'scopes' do
    it '.ordered orders by position' do
      product = create(:product, store: store)
      img2 = create(:product_image, product: product, store: store, position: 2)
      img1 = create(:product_image, product: product, store: store, position: 1)
      expect(ProductImage.ordered.first).to eq(img1)
    end
  end
end
