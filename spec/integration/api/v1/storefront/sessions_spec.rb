require 'swagger_helper'

RSpec.describe 'Storefront Sessions', type: :request do
  # store, X-Store-Domain, and Current.store are provided by the
  # 'storefront_store_domain' shared context in swagger_helper.rb.

  let(:customer) { create(:customer, store: store, email: 'customer@test.com', password: 'password123') }

  path '/api/v1/storefront/session' do
    post 'Customer login' do
      tags 'Storefront / Sessions'
      consumes 'application/json'
      produces 'application/json'
      security [store_domain: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'customer@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      response '200', 'Logged in successfully' do
        let(:body) { { email: customer.email, password: 'password123' } }
        schema type: :object, properties: {
          customer: { '$ref': '#/components/schemas/customer' },
          token: { type: :string, description: 'JWT token valid for 24 hours. Send as X-Customer-Token header.' }
        }
        run_test!
      end

      response '401', 'Invalid email or password' do
        let(:body) { { email: 'wrong@example.com', password: 'wrong' } }
        schema type: :object, properties: {
          error: { type: :string }
        }
        run_test!
      end
    end
  end
end
