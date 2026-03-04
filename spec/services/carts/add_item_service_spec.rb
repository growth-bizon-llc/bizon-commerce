require 'rails_helper'

RSpec.describe Carts::AddItemService do
  let(:store) { create(:store) }
  let(:cart) { create(:cart, store: store) }
  let(:product) { create(:product, :active, store: store, base_price_cents: 2500, quantity: 10) }

  before { Current.store = store }

  describe '#call' do
    context 'with valid product' do
      it 'adds item to cart' do
        service = described_class.new(cart: cart, product: product, quantity: 1)
        service.call

        expect(service).to be_success
        expect(cart.cart_items.count).to eq(1)
        expect(service.result.unit_price_cents).to eq(2500)
      end

      it 'increments quantity if product already in cart' do
        create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 1)

        service = described_class.new(cart: cart, product: product, quantity: 2)
        service.call

        expect(service).to be_success
        expect(cart.cart_items.count).to eq(1)
        expect(cart.cart_items.first.quantity).to eq(3)
      end
    end

    context 'with variant' do
      let(:variant) { create(:product_variant, product: product, store: store, price_cents: 3000, quantity: 5) }

      it 'uses variant price' do
        service = described_class.new(cart: cart, product: product, variant: variant, quantity: 1)
        service.call

        expect(service).to be_success
        expect(service.result.unit_price_cents).to eq(3000)
      end

      it 'fails if variant is inactive' do
        variant.update!(active: false)
        service = described_class.new(cart: cart, product: product, variant: variant, quantity: 1)
        service.call

        expect(service).not_to be_success
        expect(service.errors).to include("Variant is not available")
      end
    end

    context 'with insufficient stock' do
      it 'fails when not enough stock' do
        product.update!(quantity: 2)
        service = described_class.new(cart: cart, product: product, quantity: 5)
        service.call

        expect(service).not_to be_success
        expect(service.errors.first).to include("Not enough stock")
      end

      it 'considers existing cart items in stock check' do
        create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 8)

        service = described_class.new(cart: cart, product: product, quantity: 5)
        service.call

        expect(service).not_to be_success
      end
    end

    context 'with invalid quantity' do
      it 'fails with zero quantity' do
        service = described_class.new(cart: cart, product: product, quantity: 0)
        service.call

        expect(service).not_to be_success
        expect(service.errors).to include("Quantity must be greater than 0")
      end

      it 'fails with negative quantity' do
        service = described_class.new(cart: cart, product: product, quantity: -1)
        service.call

        expect(service).not_to be_success
      end
    end

    context 'with inactive product' do
      it 'fails' do
        product.update!(status: 'draft')
        service = described_class.new(cart: cart, product: product, quantity: 1)
        service.call

        expect(service).not_to be_success
        expect(service.errors).to include("Product is not available")
      end
    end

    context 'without inventory tracking' do
      it 'allows adding any quantity' do
        product.update!(track_inventory: false, quantity: 0)
        service = described_class.new(cart: cart, product: product, quantity: 100)
        service.call

        expect(service).to be_success
      end
    end

    context 'when database error occurs during transaction' do
      it 'handles RecordInvalid gracefully' do
        allow_any_instance_of(Cart).to receive(:add_item).and_raise(
          ActiveRecord::RecordInvalid.new(CartItem.new)
        )

        service = described_class.new(cart: cart, product: product, quantity: 1)
        service.call

        expect(service).not_to be_success
        expect(service.errors).to be_present
      end
    end
  end
end
