require 'swagger_helper'

RSpec.describe 'Storefront Categories', type: :request do
  # store, X-Store-Domain, and Current.store are provided by the
  # 'storefront_store_domain' shared context defined in swagger_helper.rb.

  path '/api/v1/storefront/categories' do
    get 'List categories' do
      tags 'Storefront / Categories'
      produces 'application/json'
      security [store_domain: []]

      response '200', 'Categories list' do
        before { create_list(:category, 2, store: store) }

        schema type: :object, properties: {
          categories: {
            type: :array,
            items: { '$ref': '#/components/schemas/category' }
          }
        }
        run_test!
      end
    end
  end

  path '/api/v1/storefront/categories/{slug}' do
    parameter name: :slug, in: :path, type: :string, required: true, description: 'Category slug'

    get 'Get category with products' do
      tags 'Storefront / Categories'
      produces 'application/json'
      security [store_domain: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'Category with products' do
        let(:category) { create(:category, store: store) }
        let(:slug) { category.slug }

        schema type: :object, properties: {
          category: { '$ref': '#/components/schemas/category' },
          products: {
            type: :array,
            items: { '$ref': '#/components/schemas/product_list' }
          },
          meta: { '$ref': '#/components/schemas/pagination_meta' }
        }
        run_test!
      end

      response '404', 'Not found' do
        let(:slug) { 'nonexistent-category' }
        run_test!
      end
    end
  end
end
