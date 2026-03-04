require 'swagger_helper'

RSpec.describe 'Storefront Cart', type: :request do
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
          product_id: { type: :integer },
          variant_id: { type: :integer, nullable: true, description: 'Required if product has variants' },
          quantity: { type: :integer, default: 1, minimum: 1 }
        },
        required: %w[product_id]
      }

      response '200', 'Item added' do
        header 'X-Cart-Token', schema: { type: :string }, description: 'Cart token'
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
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
          cart_item_id: { type: :integer },
          quantity: { type: :integer, minimum: 1 }
        },
        required: %w[cart_item_id quantity]
      }

      response '200', 'Item updated' do
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
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
          cart_item_id: { type: :integer }
        },
        required: %w[cart_item_id]
      }

      response '200', 'Item removed' do
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end

      response '422', 'Invalid parameters' do
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
        schema '$ref': '#/components/schemas/cart'
        run_test!
      end
    end
  end
end
