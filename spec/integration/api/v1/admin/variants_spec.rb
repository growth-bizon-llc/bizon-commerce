require 'swagger_helper'

RSpec.describe 'Admin Variants', type: :request do
  path '/api/v1/admin/products/{product_id}/variants' do
    parameter name: :product_id, in: :path, type: :integer, required: true, description: 'Product ID'

    get 'List variants' do
      tags 'Admin / Variants'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Variants list' do
        schema type: :object, properties: {
          variants: {
            type: :array,
            items: { '$ref': '#/components/schemas/variant' }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    post 'Create variant' do
      tags 'Admin / Variants'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          variant: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Large / Blue' },
              sku: { type: :string, example: 'TSH-001-LG-BL' },
              price_cents: { type: :integer, example: 3499 },
              price_currency: { type: :string, example: 'USD' },
              compare_at_price_cents: { type: :integer, nullable: true },
              compare_at_price_currency: { type: :string },
              track_inventory: { type: :boolean, default: true },
              quantity: { type: :integer, default: 0 },
              position: { type: :integer },
              active: { type: :boolean, default: true },
              options: { type: :object, example: { size: 'L', color: 'Blue' } }
            },
            required: %w[name price_cents]
          }
        },
        required: %w[variant]
      }

      response '201', 'Variant created' do
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '422', 'Invalid parameters' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/products/{product_id}/variants/{id}' do
    parameter name: :product_id, in: :path, type: :integer, required: true, description: 'Product ID'
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Variant ID'

    get 'Get variant' do
      tags 'Admin / Variants'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Variant found' do
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end

    patch 'Update variant' do
      tags 'Admin / Variants'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          variant: {
            type: :object,
            properties: {
              name: { type: :string },
              sku: { type: :string },
              price_cents: { type: :integer },
              price_currency: { type: :string },
              compare_at_price_cents: { type: :integer, nullable: true },
              compare_at_price_currency: { type: :string },
              track_inventory: { type: :boolean },
              quantity: { type: :integer },
              position: { type: :integer },
              active: { type: :boolean },
              options: { type: :object }
            }
          }
        }
      }

      response '200', 'Variant updated' do
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end

      response '422', 'Invalid parameters' do
        run_test!
      end
    end

    delete 'Delete variant' do
      tags 'Admin / Variants'
      security [bearer_auth: []]

      response '204', 'Variant deleted' do
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end
  end
end
