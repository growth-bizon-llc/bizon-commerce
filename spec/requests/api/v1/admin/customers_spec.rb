require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Customers', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/customers' do
    let!(:customer1) { create(:customer, store: store, email: 'alice@test.com') }
    let!(:customer2) { create(:customer, store: store, email: 'bob@test.com') }

    it 'returns all customers' do
      get '/api/v1/admin/customers', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['customers'].size).to eq(2)
    end

    it 'searches by email' do
      get '/api/v1/admin/customers', params: { q: 'alice' }, headers: headers

      expect(json_response['customers'].size).to eq(1)
      expect(json_response['customers'].first['email']).to eq('alice@test.com')
    end
  end

  describe 'GET /api/v1/admin/customers/:id' do
    let!(:customer) { create(:customer, store: store) }

    it 'returns customer details' do
      get "/api/v1/admin/customers/#{customer.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(customer.id)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
