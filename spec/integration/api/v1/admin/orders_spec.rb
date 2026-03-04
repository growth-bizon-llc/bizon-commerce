require 'swagger_helper'

RSpec.describe 'Admin Orders', type: :request do
  # store, user, Authorization, and Current.store are provided by the
  # 'admin_bearer_auth' shared context defined in swagger_helper.rb.

  path '/api/v1/admin/orders' do
    get 'List orders' do
      tags 'Admin / Orders'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false,
                enum: %w[pending confirmed paid processing shipped delivered cancelled refunded],
                description: 'Filter by status'

      response '200', 'Orders list' do
        before { create_list(:order, 2, store: store) }

        schema type: :object, properties: {
          orders: {
            type: :array,
            items: { '$ref': '#/components/schemas/order_list' }
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
  end

  path '/api/v1/admin/orders/{id}' do
    parameter name: :id, in: :path, type: :string, required: true, description: 'Order ID'

    let(:order) { create(:order, :with_items, store: store) }
    let(:id) { order.id }

    get 'Get order' do
      tags 'Admin / Orders'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Order found' do
        schema '$ref': '#/components/schemas/order'
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

    patch 'Update order status' do
      tags 'Admin / Orders'
      description 'Trigger a state transition event on the order. Valid events: confirm, pay, process_order, ship, deliver, cancel, refund.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          event: {
            type: :string,
            enum: %w[confirm pay process_order ship deliver cancel refund],
            description: 'State transition event to trigger'
          }
        },
        required: %w[event]
      }

      response '200', 'Order status updated' do
        let(:body) { { event: 'confirm' } }
        schema '$ref': '#/components/schemas/order'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { event: 'confirm' } }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:body) { { event: 'confirm' } }
        run_test!
      end

      response '422', 'Invalid transition' do
        let(:order) { create(:order, :delivered, store: store) }
        let(:body) { { event: 'confirm' } }
        schema type: :object, properties: {
          errors: { type: :array, items: { type: :string } }
        }
        run_test!
      end
    end
  end
end
