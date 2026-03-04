require 'swagger_helper'

RSpec.describe 'Admin Variants', type: :request do
  # store, user, Authorization, and Current.store are provided by the
  # 'admin_bearer_auth' shared context defined in swagger_helper.rb.

  let(:product) { create(:product, store: store) }

  path '/api/v1/admin/products/{product_id}/variants' do
    parameter name: :product_id, in: :path, type: :string, required: true, description: 'Product ID'

    let(:product_id) { product.id }

    get 'List variants' do
      tags 'Admin / Variants'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Variants list' do
        before { create_list(:product_variant, 2, product: product, store: store) }

        schema type: :object, properties: {
          variants: {
            type: :array,
            items: { '$ref': '#/components/schemas/variant' }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
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
        let(:body) { { variant: { name: 'Large / Blue', price_cents: 3499 } } }
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { variant: { name: 'Large / Blue', price_cents: 3499 } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:body) { { variant: { name: '', price_cents: nil } } }
        run_test!
      end
    end
  end

  path '/api/v1/admin/products/{product_id}/variants/{id}' do
    parameter name: :product_id, in: :path, type: :string, required: true, description: 'Product ID'
    parameter name: :id, in: :path, type: :string, required: true, description: 'Variant ID'

    let(:product_id) { product.id }
    let(:variant) { create(:product_variant, product: product, store: store) }
    let(:id) { variant.id }

    get 'Get variant' do
      tags 'Admin / Variants'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Variant found' do
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
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
        let(:body) { { variant: { name: 'Updated Variant' } } }
        schema '$ref': '#/components/schemas/variant'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { variant: { name: 'Updated' } } }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:body) { { variant: { name: 'Updated' } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:body) { { variant: { name: '' } } }
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
        let(:Authorization) { nil }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        run_test!
      end
    end
  end
end
