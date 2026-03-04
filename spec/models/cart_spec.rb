require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    subject { build(:cart, store: store) }

    it 'auto-generates token if blank' do
      cart = Cart.create!(store: store)
      expect(cart.token).to be_present
    end

    it 'validates uniqueness of token' do
      create(:cart, store: store, token: 'unique-token-123')
      cart2 = build(:cart, store: store, token: 'unique-token-123')
      expect(cart2).not_to be_valid
      expect(cart2.errors[:token]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:customer).optional }
    it { should have_many(:cart_items).dependent(:destroy) }
  end

  describe 'token generation' do
    it 'generates token before create' do
      cart = Cart.create!(store: store)
      expect(cart.token).to be_present
      expect(cart.token.length).to be > 20
    end

    it 'does not overwrite existing token' do
      cart = Cart.create!(store: store, token: 'my-custom-token')
      expect(cart.token).to eq('my-custom-token')
    end
  end

  describe '#total' do
    it 'returns sum of all cart item totals' do
      product = create(:product, :active, store: store, base_price_cents: 2500)
      cart = create(:cart, store: store)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 2)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 1000, quantity: 1)

      expect(cart.total).to eq(6000)
    end

    it 'returns 0 for empty cart' do
      cart = create(:cart, store: store)
      expect(cart.total).to eq(0)
    end
  end

  describe '#items_count' do
    it 'returns sum of all quantities' do
      product = create(:product, :active, store: store)
      cart = create(:cart, store: store)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 1000, quantity: 2)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 1000, quantity: 3)

      expect(cart.items_count).to eq(5)
    end
  end

  describe '#add_item' do
    let(:product) { create(:product, :active, store: store, base_price_cents: 2500) }
    let(:cart) { create(:cart, store: store) }

    it 'adds a new item to the cart' do
      item = cart.add_item(product)
      expect(cart.cart_items.count).to eq(1)
      expect(item.quantity).to eq(1)
      expect(item.unit_price_cents).to eq(2500)
    end

    it 'increments quantity if item already exists' do
      cart.add_item(product)
      cart.add_item(product, nil, 2)
      expect(cart.cart_items.count).to eq(1)
      expect(cart.cart_items.first.quantity).to eq(3)
    end

    it 'uses variant price when variant provided' do
      variant = create(:product_variant, product: product, store: store, price_cents: 3000)
      item = cart.add_item(product, variant)
      expect(item.unit_price_cents).to eq(3000)
    end
  end

  describe '#remove_item' do
    it 'removes an item from the cart' do
      product = create(:product, :active, store: store)
      cart = create(:cart, store: store)
      item = create(:cart_item, cart: cart, product: product, unit_price_cents: 1000)

      cart.remove_item(item.id)
      expect(cart.cart_items.count).to eq(0)
    end
  end

  describe '#clear!' do
    it 'removes all items' do
      product = create(:product, :active, store: store)
      cart = create(:cart, store: store)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 1000)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 2000)

      cart.clear!
      expect(cart.cart_items.count).to eq(0)
    end
  end

  describe 'scopes' do
    let!(:active_cart) { create(:cart, store: store, status: 'active') }
    let!(:abandoned_cart) { create(:cart, store: store, status: 'abandoned') }

    it '.active returns active carts' do
      expect(Cart.active).to include(active_cart)
      expect(Cart.active).not_to include(abandoned_cart)
    end

    it '.abandoned returns abandoned carts' do
      expect(Cart.abandoned).to include(abandoned_cart)
      expect(Cart.abandoned).not_to include(active_cart)
    end
  end
end
