require 'swagger_helper'

RSpec.describe 'Storefront Orders', type: :request do
  # store, X-Store-Domain, X-Cart-Token, X-Customer-Token, and Current.store
  # are provided by the 'storefront_store_domain' shared context in swagger_helper.rb.

  let(:product) { create(:product, :active, store: store, base_price_cents: 2500) }

  path '/api/v1/storefront/orders' do
    post 'Create order (checkout)' do
      tags 'Storefront / Orders'
      description 'Creates an order from the current cart. Requires a valid cart token with items.'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: [], cart_token: [], customer_token: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'customer@example.com', description: 'Required if not logged in' },
          shipping_address: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              address1: { type: :string },
              address2: { type: :string },
              city: { type: :string },
              state: { type: :string },
              zip: { type: :string },
              country: { type: :string },
              phone: { type: :string }
            }
          },
          billing_address: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              address1: { type: :string },
              address2: { type: :string },
              city: { type: :string },
              state: { type: :string },
              zip: { type: :string },
              country: { type: :string },
              phone: { type: :string }
            }
          },
          notes: { type: :string, nullable: true }
        },
        required: %w[email shipping_address]
      }

      response '201', 'Order created' do
        let(:cart) { create(:cart, store: store) }

        before do
          create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 1)
        end

        let(:'X-Cart-Token') { cart.token }
        let(:body) do
          {
            email: 'buyer@test.com',
            shipping_address: { line1: '123 Main St', city: 'NY', state: 'NY', zip: '10001' }
          }
        end

        schema '$ref': '#/components/schemas/order'
        run_test!
      end

      response '422', 'Invalid parameters or empty cart' do
        let(:empty_cart) { create(:cart, store: store) }
        let(:'X-Cart-Token') { empty_cart.token }
        let(:body) { { email: 'test@test.com', shipping_address: {} } }
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/orders/{order_number}' do
    parameter name: :order_number, in: :path, type: :string, required: true,
              description: 'Order number (e.g., #1001)', example: '#1001'

    get 'Get order' do
      tags 'Storefront / Orders'
      produces 'application/json'
      security [store_domain: []]

      response '200', 'Order found' do
        let(:order_number) { '2001' }

        before { create(:order, :with_items, store: store, order_number: '#2001') }

        schema '$ref': '#/components/schemas/order'
        run_test!
      end

      response '404', 'Not found' do
        let(:order_number) { '9999' }
        run_test!
      end
    end
  end
end
