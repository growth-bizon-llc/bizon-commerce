require 'swagger_helper'

RSpec.describe 'Storefront Products', type: :request do
  path '/api/v1/storefront/products' do
    get 'List products' do
      tags 'Storefront / Products'
      produces 'application/json'
      security [store_domain: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category'
      parameter name: :q, in: :query, type: :string, required: false, description: 'Search by name'
      parameter name: :featured, in: :query, type: :boolean, required: false, description: 'Filter featured products'
      parameter name: :in_stock, in: :query, type: :boolean, required: false, description: 'Filter in-stock products'

      response '200', 'Products list' do
        schema type: :object, properties: {
          products: {
            type: :array,
            items: { '$ref': '#/components/schemas/product_list' }
          },
          meta: { '$ref': '#/components/schemas/pagination_meta' }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/products/{slug}' do
    parameter name: :slug, in: :path, type: :string, required: true, description: 'Product slug'

    get 'Get product' do
      tags 'Storefront / Products'
      produces 'application/json'
      security [store_domain: []]

      response '200', 'Product found' do
        schema '$ref': '#/components/schemas/product'
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end
  end
end
