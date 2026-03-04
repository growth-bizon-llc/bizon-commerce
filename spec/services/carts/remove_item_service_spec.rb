require 'rails_helper'

RSpec.describe Carts::RemoveItemService do
  let(:store) { create(:store) }
  let(:cart) { create(:cart, store: store) }
  let(:product) { create(:product, :active, store: store) }

  before { Current.store = store }

  describe '#call' do
    it 'removes item from cart' do
      item = create(:cart_item, cart: cart, product: product, unit_price_cents: 1000)

      service = described_class.new(cart: cart, cart_item_id: item.id)
      service.call

      expect(service).to be_success
      expect(cart.cart_items.count).to eq(0)
    end

    it 'fails when item not found' do
      service = described_class.new(cart: cart, cart_item_id: SecureRandom.uuid)
      service.call

      expect(service).not_to be_success
      expect(service.errors).to include("Cart item not found")
    end

    it 'handles RecordNotDestroyed gracefully' do
      item = create(:cart_item, cart: cart, product: product, unit_price_cents: 1000)
      allow_any_instance_of(CartItem).to receive(:destroy!).and_raise(
        ActiveRecord::RecordNotDestroyed.new("Cannot destroy", item)
      )

      service = described_class.new(cart: cart, cart_item_id: item.id)
      service.call

      expect(service).not_to be_success
    end
  end
end
