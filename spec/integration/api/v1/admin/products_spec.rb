require 'swagger_helper'

RSpec.describe 'Admin Products', type: :request do
  # store, user, Authorization, and Current.store are provided by the
  # 'admin_bearer_auth' shared context defined in swagger_helper.rb.

  path '/api/v1/admin/products' do
    get 'List products' do
      tags 'Admin / Products'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, enum: %w[draft active archived], description: 'Filter by status'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category'
      parameter name: :q, in: :query, type: :string, required: false, description: 'Search by name'
      parameter name: :featured, in: :query, type: :boolean, required: false, description: 'Filter featured products'

      response '200', 'Products list' do
        before { create_list(:product, 2, store: store) }

        schema type: :object, properties: {
          products: {
            type: :array,
            items: { '$ref': '#/components/schemas/product_list' }
          },
          meta: { '$ref': '#/components/schemas/pagination_meta' }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post 'Create product' do
      tags 'Admin / Products'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Premium T-Shirt' },
              description: { type: :string },
              short_description: { type: :string },
              category_id: { type: :string },
              base_price_cents: { type: :integer, example: 2999 },
              base_price_currency: { type: :string, example: 'USD' },
              compare_at_price_cents: { type: :integer, nullable: true },
              compare_at_price_currency: { type: :string },
              sku: { type: :string, example: 'TSH-001' },
              barcode: { type: :string },
              track_inventory: { type: :boolean, default: true },
              quantity: { type: :integer, default: 0 },
              status: { type: :string, enum: %w[draft active archived], default: 'draft' },
              featured: { type: :boolean, default: false },
              position: { type: :integer },
              published_at: { type: :string, format: 'date-time', nullable: true },
              custom_attributes: { type: :object }
            },
            required: %w[name base_price_cents]
          }
        },
        required: %w[product]
      }

      response '201', 'Product created' do
        let(:body) { { product: { name: 'Premium T-Shirt', base_price_cents: 2999 } } }
        schema '$ref': '#/components/schemas/product'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { product: { name: 'Premium T-Shirt', base_price_cents: 2999 } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:body) { { product: { name: '', base_price_cents: nil } } }
        run_test!
      end
    end
  end

  path '/api/v1/admin/products/{id}' do
    parameter name: :id, in: :path, type: :string, required: true, description: 'Product ID'

    let(:product) { create(:product, store: store) }
    let(:id) { product.id }

    get 'Get product' do
      tags 'Admin / Products'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Product found' do
        schema '$ref': '#/components/schemas/product'
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

    patch 'Update product' do
      tags 'Admin / Products'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              short_description: { type: :string },
              category_id: { type: :string },
              base_price_cents: { type: :integer },
              base_price_currency: { type: :string },
              compare_at_price_cents: { type: :integer, nullable: true },
              compare_at_price_currency: { type: :string },
              sku: { type: :string },
              barcode: { type: :string },
              track_inventory: { type: :boolean },
              quantity: { type: :integer },
              status: { type: :string, enum: %w[draft active archived] },
              featured: { type: :boolean },
              position: { type: :integer },
              published_at: { type: :string, format: 'date-time', nullable: true },
              custom_attributes: { type: :object }
            }
          }
        }
      }

      response '200', 'Product updated' do
        let(:body) { { product: { name: 'Updated Product' } } }
        schema '$ref': '#/components/schemas/product'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { product: { name: 'Updated' } } }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:body) { { product: { name: 'Updated' } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:body) { { product: { name: '' } } }
        run_test!
      end
    end

    delete 'Delete product' do
      tags 'Admin / Products'
      security [bearer_auth: []]

      response '204', 'Product deleted' do
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
