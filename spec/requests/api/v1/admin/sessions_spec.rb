require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Sessions', type: :request do
  let(:store) { create(:store) }
  let(:user) { create(:user, :owner, store: store, password: 'password123') }

  describe 'POST /api/v1/admin/auth/sign_in' do
    it 'returns JWT token on successful login' do
      post '/api/v1/admin/auth/sign_in',
           params: { user: { email: user.email, password: 'password123' } },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers['Authorization']).to be_present
      expect(json_response['user']['email']).to eq(user.email)
    end

    it 'returns error on invalid credentials' do
      post '/api/v1/admin/auth/sign_in',
           params: { user: { email: user.email, password: 'wrong' } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/admin/auth/sign_out' do
    it 'signs out user' do
      headers = auth_headers_for(user)
      delete '/api/v1/admin/auth/sign_out', headers: headers

      expect(response).to have_http_status(:ok)
    end

    it 'returns unauthorized without token' do
      delete '/api/v1/admin/auth/sign_out'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
