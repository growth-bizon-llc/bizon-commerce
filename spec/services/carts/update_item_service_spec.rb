require 'rails_helper'

RSpec.describe Carts::UpdateItemService do
  let(:store) { create(:store) }
  let(:cart) { create(:cart, store: store) }
  let(:product) { create(:product, :active, store: store, quantity: 10) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, unit_price_cents: 1000, quantity: 1) }

  before { Current.store = store }

  describe '#call' do
    it 'updates item quantity' do
      service = described_class.new(cart: cart, cart_item_id: cart_item.id, quantity: 3)
      service.call

      expect(service).to be_success
      expect(cart_item.reload.quantity).to eq(3)
    end

    it 'fails with zero quantity' do
      service = described_class.new(cart: cart, cart_item_id: cart_item.id, quantity: 0)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include("Quantity must be greater than 0")
    end

    it 'fails when item not found' do
      service = described_class.new(cart: cart, cart_item_id: SecureRandom.uuid, quantity: 2)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include("Cart item not found")
    end

    it 'fails when not enough stock' do
      service = described_class.new(cart: cart, cart_item_id: cart_item.id, quantity: 100)
      service.call

      expect(service).not_to be_success
      expect(service.errors.first).to include("Not enough stock")
    end

    it 'handles RecordInvalid gracefully' do
      allow_any_instance_of(CartItem).to receive(:update!).and_raise(
        ActiveRecord::RecordInvalid.new(CartItem.new)
      )

      service = described_class.new(cart: cart, cart_item_id: cart_item.id, quantity: 2)
      service.call

      expect(service).not_to be_success
    end

    it 'skips stock check when not tracking inventory' do
      product.update!(track_inventory: false)
      service = described_class.new(cart: cart, cart_item_id: cart_item.id, quantity: 999)
      service.call

      expect(service).to be_success
    end
  end
end
