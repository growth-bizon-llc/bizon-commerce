require 'swagger_helper'

RSpec.describe 'Admin Categories', type: :request do
  path '/api/v1/admin/categories' do
    get 'List categories' do
      tags 'Admin / Categories'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'Categories list' do
        schema type: :object, properties: {
          categories: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                slug: { type: :string },
                description: { type: :string, nullable: true },
                position: { type: :integer, nullable: true },
                active: { type: :boolean },
                parent_id: { type: :integer, nullable: true },
                children_count: { type: :integer },
                products_count: { type: :integer },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' }
              }
            }
          },
          meta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              per_page: { type: :integer },
              total_pages: { type: :integer },
              total_count: { type: :integer }
            }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    post 'Create category' do
      tags 'Admin / Categories'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Electronics' },
              description: { type: :string },
              parent_id: { type: :integer, nullable: true },
              position: { type: :integer },
              active: { type: :boolean, default: true }
            },
            required: %w[name]
          }
        },
        required: %w[category]
      }

      response '201', 'Category created' do
        schema '$ref': '#/components/schemas/category'
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

  path '/api/v1/admin/categories/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Category ID'

    get 'Get category' do
      tags 'Admin / Categories'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Category found' do
        schema '$ref': '#/components/schemas/category'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end

    patch 'Update category' do
      tags 'Admin / Categories'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          category: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              parent_id: { type: :integer, nullable: true },
              position: { type: :integer },
              active: { type: :boolean }
            }
          }
        }
      }

      response '200', 'Category updated' do
        schema '$ref': '#/components/schemas/category'
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

    delete 'Delete category' do
      tags 'Admin / Categories'
      security [bearer_auth: []]

      response '204', 'Category deleted' do
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
