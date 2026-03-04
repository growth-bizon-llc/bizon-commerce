require 'rails_helper'

RSpec.describe 'Serializers' do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe ProductSerializer do
    it 'serializes compare_at_price as nil when not set' do
      product = create(:product, store: store, compare_at_price_cents: nil)
      result = described_class.new(product).to_h
      expect(result['compare_at_price']).to be_nil
    end

    it 'serializes compare_at_price when set' do
      product = create(:product, store: store, compare_at_price_cents: 5000)
      result = described_class.new(product).to_h
      expect(result['compare_at_price'][:amount]).to eq(50.0)
    end
  end

  describe ProductListSerializer do
    it 'serializes compare_at_price as nil when not set' do
      product = create(:product, store: store, compare_at_price_cents: nil)
      result = described_class.new(product).to_h
      expect(result['compare_at_price']).to be_nil
    end

    it 'serializes compare_at_price when set' do
      product = create(:product, store: store, compare_at_price_cents: 5000)
      result = described_class.new(product).to_h
      expect(result['compare_at_price'][:amount]).to eq(50.0)
    end
  end

  describe VariantSerializer do
    it 'serializes compare_at_price as nil when not set' do
      product = create(:product, store: store)
      variant = create(:product_variant, product: product, store: store, compare_at_price_cents: nil)
      result = described_class.new(variant).to_h
      expect(result['compare_at_price']).to be_nil
    end

    it 'serializes compare_at_price when set' do
      product = create(:product, store: store)
      variant = create(:product_variant, product: product, store: store, compare_at_price_cents: 5000)
      result = described_class.new(variant).to_h
      expect(result['compare_at_price'][:amount]).to eq(50.0)
    end
  end

  describe OrderListSerializer do
    it 'serializes customer_name as nil when no customer' do
      order = create(:order, store: store, customer: nil)
      result = described_class.new(order).to_h
      expect(result['customer_name']).to be_nil
    end

    it 'serializes customer_name when customer present' do
      customer = create(:customer, store: store, first_name: 'John', last_name: 'Doe')
      order = create(:order, store: store, customer: customer)
      result = described_class.new(order).to_h
      expect(result['customer_name']).to eq('John Doe')
    end
  end

  describe OrderSerializer do
    it 'serializes customer as nil when no customer' do
      order = create(:order, store: store, customer: nil)
      result = described_class.new(order).to_h
      expect(result['customer']).to be_nil
    end
  end
end
