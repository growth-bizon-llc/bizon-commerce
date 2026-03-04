require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Stores', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let(:staff_user) { create(:user, :staff, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }

  describe 'GET /api/v1/admin/store' do
    it 'returns current store' do
      get '/api/v1/admin/store', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(store.id)
      expect(json_response['name']).to eq(store.name)
    end
  end

  describe 'PATCH /api/v1/admin/store' do
    it 'owner can update store' do
      patch '/api/v1/admin/store',
            params: { store: { name: 'Updated Store', description: 'New desc' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq('Updated Store')
    end

    it 'staff cannot update store' do
      staff_headers = auth_headers_for(staff_user)
      patch '/api/v1/admin/store',
            params: { store: { name: 'Hacked' } },
            headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
