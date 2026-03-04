require 'swagger_helper'

RSpec.describe 'Admin Dashboard', type: :request do
  # store, user, Authorization, and Current.store are provided by the
  # 'admin_bearer_auth' shared context defined in swagger_helper.rb.

  path '/api/v1/admin/dashboard' do
    get 'Get dashboard metrics' do
      tags 'Admin / Dashboard'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Dashboard data' do
        schema type: :object, properties: {
          total_products: { type: :integer },
          total_orders: { type: :integer },
          total_customers: { type: :integer },
          total_revenue_cents: { type: :integer },
          orders_by_status: { type: :object },
          recent_orders: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string, format: :uuid },
                order_number: { type: :string },
                email: { type: :string },
                status: { type: :string },
                total: {
                  type: :object,
                  properties: {
                    amount: { type: :number },
                    currency: { type: :string }
                  }
                },
                items_count: { type: :integer },
                customer_name: { type: :string, nullable: true },
                created_at: { type: :string, format: 'date-time' }
              }
            }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
