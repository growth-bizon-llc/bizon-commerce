require 'swagger_helper'

RSpec.describe 'Admin Auth', type: :request do
  path '/api/v1/admin/auth/sign_in' do
    post 'Sign in' do
      tags 'Admin / Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'admin@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        },
        required: %w[user]
      }

      response '200', 'Signed in successfully' do
        schema type: :object, properties: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              role: { type: :string, enum: %w[staff admin owner] },
              full_name: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          message: { type: :string }
        }
        run_test!
      end

      response '401', 'Invalid credentials' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/auth/sign_out' do
    delete 'Sign out' do
      tags 'Admin / Auth'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Signed out successfully' do
        schema type: :object, properties: {
          message: { type: :string }
        }
        run_test!
      end

      response '401', 'Already logged out' do
        run_test!
      end
    end
  end
end
