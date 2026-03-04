require 'swagger_helper'

RSpec.describe 'Storefront Orders', type: :request do
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
        schema '$ref': '#/components/schemas/order'
        run_test!
      end

      response '422', 'Invalid parameters or empty cart' do
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
        schema '$ref': '#/components/schemas/order'
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end
  end
end
