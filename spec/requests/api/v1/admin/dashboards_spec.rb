require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Dashboards', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/dashboard' do
    let!(:product) { create(:product, :active, store: store) }
    let!(:order) { create(:order, :paid, store: store) }
    let!(:customer) { create(:customer, store: store) }

    it 'returns dashboard stats' do
      get '/api/v1/admin/dashboard', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response).to include('total_products', 'total_orders', 'total_customers', 'total_revenue_cents')
    end

    it 'requires authentication' do
      get '/api/v1/admin/dashboard', as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
