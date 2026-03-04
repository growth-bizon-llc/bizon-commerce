require 'swagger_helper'

RSpec.describe 'Storefront Customers', type: :request do
  # store, X-Store-Domain, and Current.store are provided by the
  # 'storefront_store_domain' shared context in swagger_helper.rb.

  path '/api/v1/storefront/customers' do
    post 'Register customer' do
      tags 'Storefront / Customers'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              email: { type: :string, example: 'customer@example.com' },
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' },
              phone: { type: :string, example: '+1234567890' },
              password: { type: :string, example: 'password123', minimum: 6 },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: %w[email password password_confirmation]
          }
        },
        required: %w[customer]
      }

      response '201', 'Customer registered' do
        let(:body) do
          {
            customer: {
              email: 'new@customer.com',
              first_name: 'Jane',
              last_name: 'Doe',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end
        schema type: :object, properties: {
          customer: { '$ref': '#/components/schemas/customer' },
          token: { type: :string, description: 'JWT token valid for 24 hours. Send as X-Customer-Token header.' }
        }
        run_test!
      end

      response '422', 'Validation errors' do
        let(:body) do
          {
            customer: {
              email: '',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end
end
