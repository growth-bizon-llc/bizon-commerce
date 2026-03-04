require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Orders', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let(:staff_user) { create(:user, :staff, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/orders' do
    let!(:order1) { create(:order, store: store) }
    let!(:order2) { create(:order, :paid, store: store) }

    it 'returns all orders' do
      get '/api/v1/admin/orders', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['orders'].size).to eq(2)
    end

    it 'filters by status' do
      get '/api/v1/admin/orders', params: { status: 'paid' }, headers: headers

      expect(json_response['orders'].size).to eq(1)
    end

    it 'staff can list orders' do
      staff_headers = auth_headers_for(staff_user)
      get '/api/v1/admin/orders', headers: staff_headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /api/v1/admin/orders/:id' do
    let!(:order) { create(:order, :with_items, store: store) }

    it 'returns order details' do
      get "/api/v1/admin/orders/#{order.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(order.id)
      expect(json_response['items']).to be_present
    end
  end

  describe 'PATCH /api/v1/admin/orders/:id' do
    let!(:order) { create(:order, store: store) }

    it 'updates order status (owner)' do
      patch "/api/v1/admin/orders/#{order.id}",
            params: { event: 'confirm' },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('confirmed')
    end

    it 'returns error for invalid transition' do
      patch "/api/v1/admin/orders/#{order.id}",
            params: { event: 'ship' },
            headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'staff cannot update order status' do
      staff_headers = auth_headers_for(staff_user)
      patch "/api/v1/admin/orders/#{order.id}",
            params: { event: 'confirm' },
            headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
