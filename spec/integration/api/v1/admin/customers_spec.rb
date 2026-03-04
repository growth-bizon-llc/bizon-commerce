require 'swagger_helper'

RSpec.describe 'Admin Customers', type: :request do
  path '/api/v1/admin/customers' do
    get 'List customers' do
      tags 'Admin / Customers'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :q, in: :query, type: :string, required: false, description: 'Search by email'

      response '200', 'Customers list' do
        schema type: :object, properties: {
          customers: {
            type: :array,
            items: { '$ref': '#/components/schemas/customer' }
          },
          meta: { '$ref': '#/components/schemas/pagination_meta' }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/customers/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Customer ID'

    get 'Get customer' do
      tags 'Admin / Customers'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Customer found' do
        schema '$ref': '#/components/schemas/customer'
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
