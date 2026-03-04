require 'swagger_helper'

RSpec.describe 'Storefront Cart', type: :request do
  # store, X-Store-Domain, X-Cart-Token, X-Customer-Token, and Current.store
  # are provided by the 'storefront_store_domain' shared context in swagger_helper.rb.

  let(:product) { create(:product, :active, store: store, base_price_cents: 2500, quantity: 10) }
  let(:cart) { create(:cart, store: store) }

  path '/api/v1/storefront/cart' do
    get 'Get cart' do
      tags 'Storefront / Cart'
      description 'Returns the current cart. Creates a new one if no cart token is provided. The response includes the X-Cart-Token header.'
      produces 'application/json'
      security [store_domain: [], cart_token: []]

      response '200', 'Cart retrieved' do
        header 'X-Cart-Token', schema: { type: :string }, description: 'Cart token for subsequent requests'
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end
    end
  end

  path '/api/v1/storefront/cart/add_item' do
    post 'Add item to cart' do
      tags 'Storefront / Cart'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: [], cart_token: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string },
          variant_id: { type: :string, nullable: true, description: 'Required if product has variants' },
          quantity: { type: :integer, default: 1, minimum: 1 }
        },
        required: %w[product_id]
      }

      response '200', 'Item added' do
        header 'X-Cart-Token', schema: { type: :string }, description: 'Cart token'

        let(:body) { { product_id: product.id, quantity: 1 } }
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:out_of_stock_product) { create(:product, :active, :out_of_stock, store: store) }
        let(:body) { { product_id: out_of_stock_product.id, quantity: 1 } }
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/cart/update_item' do
    patch 'Update cart item quantity' do
      tags 'Storefront / Cart'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: [], cart_token: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          cart_item_id: { type: :string },
          quantity: { type: :integer, minimum: 1 }
        },
        required: %w[cart_item_id quantity]
      }

      response '200', 'Item updated' do
        let(:cart_item) { create(:cart_item, cart: cart, product: product, unit_price_cents: 2500) }
        let(:'X-Cart-Token') { cart.token }
        let(:body) { { cart_item_id: cart_item.id, quantity: 3 } }
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:'X-Cart-Token') { cart.token }
        let(:body) { { cart_item_id: '00000000-0000-0000-0000-000000000000', quantity: 3 } }
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/cart/remove_item' do
    delete 'Remove item from cart' do
      tags 'Storefront / Cart'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: [], cart_token: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          cart_item_id: { type: :string }
        },
        required: %w[cart_item_id]
      }

      response '200', 'Item removed' do
        let(:cart_item) { create(:cart_item, cart: cart, product: product, unit_price_cents: 2500) }
        let(:'X-Cart-Token') { cart.token }
        let(:body) { { cart_item_id: cart_item.id } }
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:'X-Cart-Token') { cart.token }
        let(:body) { { cart_item_id: '00000000-0000-0000-0000-000000000000' } }
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/cart/clear' do
    delete 'Clear cart' do
      tags 'Storefront / Cart'
      produces 'application/json'
      security [store_domain: [], cart_token: []]

      response '200', 'Cart cleared' do
        let(:'X-Cart-Token') { cart.token }

        before { create(:cart_item, cart: cart, product: product, unit_price_cents: 2500) }

        schema '$ref': '#/components/schemas/cart'
        run_test!
      end
    end
  end
end
