require 'rails_helper'

RSpec.describe Products::CreateWithVariantsService do
  let(:store) { create(:store) }
  let(:category) { create(:category, store: store) }

  before { Current.store = store }

  describe '#call' do
    let(:product_params) do
      {
        name: 'Test Product',
        description: 'A test product',
        base_price_cents: 2500,
        status: 'active',
        category_id: category.id
      }
    end

    it 'creates a product' do
      service = described_class.new(store: store, product_params: product_params)
      service.call

      expect(service).to be_success
      expect(service.result.name).to eq('Test Product')
      expect(service.result.store).to eq(store)
    end

    it 'creates product with variants' do
      variants = [
        { name: 'Red / S', price_cents: 2500, sku: 'RED-S' },
        { name: 'Blue / M', price_cents: 3000, sku: 'BLU-M' }
      ]

      service = described_class.new(
        store: store,
        product_params: product_params,
        variants_params: variants
      )
      service.call

      expect(service).to be_success
      expect(service.result.variants.count).to eq(2)
      expect(service.result.variants.map(&:name)).to contain_exactly('Red / S', 'Blue / M')
    end

    it 'rolls back on invalid product' do
      invalid_params = product_params.merge(name: nil)
      service = described_class.new(store: store, product_params: invalid_params)
      service.call

      expect(service).not_to be_success
      expect(Product.count).to eq(0)
    end

    it 'rolls back variants if one fails' do
      variants = [
        { name: 'Valid', price_cents: 2500 },
        { name: nil, price_cents: 3000 }  # invalid - name is required
      ]

      service = described_class.new(
        store: store,
        product_params: product_params,
        variants_params: variants
      )
      service.call

      expect(service).not_to be_success
      expect(Product.count).to eq(0)
      expect(ProductVariant.count).to eq(0)
    end

    it 'creates product with images' do
      images = [
        { alt_text: 'Front view', file: nil },
        { alt_text: 'Side view', file: nil }
      ]

      service = described_class.new(
        store: store,
        product_params: product_params,
        images: images
      )
      service.call

      expect(service).to be_success
      expect(service.result.product_images.count).to eq(2)
      expect(service.result.product_images.map(&:alt_text)).to contain_exactly('Front view', 'Side view')
    end
  end
end
