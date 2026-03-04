require 'swagger_helper'

RSpec.describe 'Admin Store', type: :request do
  path '/api/v1/admin/store' do
    get 'Get store details' do
      tags 'Admin / Store'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Store found' do
        schema type: :object, properties: {
          id: { type: :integer },
          name: { type: :string },
          slug: { type: :string },
          custom_domain: { type: :string, nullable: true },
          subdomain: { type: :string, nullable: true },
          description: { type: :string, nullable: true },
          currency: { type: :string },
          locale: { type: :string },
          settings: { type: :object },
          active: { type: :boolean },
          created_at: { type: :string, format: 'date-time' },
          updated_at: { type: :string, format: 'date-time' }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end
    end

    patch 'Update store' do
      tags 'Admin / Store'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          store: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              custom_domain: { type: :string },
              subdomain: { type: :string },
              currency: { type: :string, example: 'USD' },
              locale: { type: :string, example: 'en' },
              active: { type: :boolean },
              settings: { type: :object }
            }
          }
        }
      }

      response '200', 'Store updated' do
        schema type: :object, properties: {
          id: { type: :integer },
          name: { type: :string },
          slug: { type: :string },
          custom_domain: { type: :string, nullable: true },
          subdomain: { type: :string, nullable: true },
          description: { type: :string, nullable: true },
          currency: { type: :string },
          locale: { type: :string },
          settings: { type: :object },
          active: { type: :boolean },
          created_at: { type: :string, format: 'date-time' },
          updated_at: { type: :string, format: 'date-time' }
        }
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
end
