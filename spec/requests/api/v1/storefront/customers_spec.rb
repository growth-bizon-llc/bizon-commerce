require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Customers', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }

  before { Current.store = store }

  describe 'POST /api/v1/storefront/customers' do
    it 'registers a new customer' do
      post '/api/v1/storefront/customers',
           params: {
             customer: {
               email: 'new@customer.com',
               first_name: 'Jane',
               last_name: 'Doe',
               password: 'password123',
               password_confirmation: 'password123'
             }
           },
           headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['customer']['email']).to eq('new@customer.com')
      expect(json_response['token']).to be_present
    end

    it 'returns error for duplicate email' do
      create(:customer, store: store, email: 'existing@test.com')

      post '/api/v1/storefront/customers',
           params: {
             customer: {
               email: 'existing@test.com',
               password: 'password123',
               password_confirmation: 'password123'
             }
           },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns error for missing email' do
      post '/api/v1/storefront/customers',
           params: {
             customer: {
               email: '',
               password: 'password123',
               password_confirmation: 'password123'
             }
           },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
