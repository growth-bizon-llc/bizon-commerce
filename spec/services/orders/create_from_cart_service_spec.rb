require 'rails_helper'

RSpec.describe Orders::CreateFromCartService do
  let(:store) { create(:store) }
  let(:cart) { create(:cart, store: store) }
  let(:product) { create(:product, :active, store: store, base_price_cents: 2500, sku: 'TST-001') }
  let(:customer) { create(:customer, store: store) }

  before do
    Current.store = store
    create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 2)
  end

  describe '#call' do
    context 'with valid cart' do
      it 'creates an order' do
        service = described_class.new(cart: cart, email: 'customer@test.com')
        service.call

        expect(service).to be_success
        expect(service.result).to be_a(Order)
        expect(service.result.email).to eq('customer@test.com')
        expect(service.result.subtotal_cents).to eq(5000)
        expect(service.result.total_cents).to eq(5000)
      end

      it 'creates order items with product snapshots' do
        service = described_class.new(cart: cart, email: 'customer@test.com')
        service.call

        item = service.result.order_items.first
        expect(item.product_name).to eq(product.name)
        expect(item.sku).to eq('TST-001')
        expect(item.quantity).to eq(2)
        expect(item.unit_price_cents).to eq(2500)
        expect(item.total_cents).to eq(5000)
      end

      it 'converts the cart status' do
        service = described_class.new(cart: cart, email: 'customer@test.com')
        service.call

        expect(cart.reload.status).to eq('converted')
      end

      it 'associates customer when provided' do
        service = described_class.new(cart: cart, email: customer.email, customer: customer)
        service.call

        expect(service.result.customer).to eq(customer)
      end

      it 'saves shipping and billing addresses' do
        shipping = { line1: '123 Main St', city: 'NY' }
        billing = { line1: '456 Oak Ave', city: 'LA' }

        service = described_class.new(
          cart: cart, email: 'test@test.com',
          shipping_address: shipping, billing_address: billing
        )
        service.call

        expect(service.result.shipping_address).to eq(shipping.stringify_keys)
        expect(service.result.billing_address).to eq(billing.stringify_keys)
      end

      it 'generates an order number' do
        service = described_class.new(cart: cart, email: 'test@test.com')
        service.call

        expect(service.result.order_number).to match(/^#\d+$/)
      end

      it 'sets placed_at' do
        service = described_class.new(cart: cart, email: 'test@test.com')
        service.call

        expect(service.result.placed_at).to be_present
      end
    end

    context 'with empty cart' do
      it 'fails' do
        empty_cart = create(:cart, store: store)
        service = described_class.new(cart: empty_cart, email: 'test@test.com')
        service.call

        expect(service).not_to be_success
        expect(service.errors).to include("Cart is empty")
      end
    end

    context 'without email' do
      it 'fails' do
        service = described_class.new(cart: cart, email: '')
        service.call

        expect(service).not_to be_success
        expect(service.errors).to include("Email is required")
      end
    end

    context 'with variant items' do
      it 'creates order items with variant info' do
        variant = create(:product_variant, product: product, store: store, name: 'Red / XL', sku: 'VAR-001', price_cents: 3000)
        create(:cart_item, cart: cart, product: product, product_variant: variant, unit_price_cents: 3000, quantity: 1)

        service = described_class.new(cart: cart, email: 'test@test.com')
        service.call

        variant_item = service.result.order_items.find { |i| i.variant_name == 'Red / XL' }
        expect(variant_item).to be_present
        expect(variant_item.sku).to eq('VAR-001')
      end
    end

    context 'when database error occurs during transaction' do
      it 'handles RecordInvalid gracefully' do
        allow(Order).to receive(:create!).and_raise(
          ActiveRecord::RecordInvalid.new(Order.new)
        )

        service = described_class.new(cart: cart, email: 'test@test.com')
        service.call

        expect(service).not_to be_success
        expect(service.errors).to be_present
      end
    end
  end
end
