require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Sessions', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }
  let!(:customer) { create(:customer, store: store, email: 'customer@test.com', password: 'password123') }

  before { Current.store = store }

  describe 'POST /api/v1/storefront/session' do
    it 'returns customer and token on success' do
      post '/api/v1/storefront/session',
           params: { email: 'customer@test.com', password: 'password123' },
           headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['token']).to be_present
      expect(json_response['customer']['email']).to eq('customer@test.com')
    end

    it 'returns 401 on invalid credentials' do
      post '/api/v1/storefront/session',
           params: { email: 'customer@test.com', password: 'wrong' },
           headers: headers, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 for non-existent email' do
      post '/api/v1/storefront/session',
           params: { email: 'notfound@test.com', password: 'password123' },
           headers: headers, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
