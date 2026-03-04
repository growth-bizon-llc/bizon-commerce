require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Categories', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let(:staff_user) { create(:user, :staff, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/categories' do
    let!(:cat1) { create(:category, store: store, name: 'Electronics') }
    let!(:cat2) { create(:category, store: store, name: 'Clothing') }

    it 'returns all categories' do
      get '/api/v1/admin/categories', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['categories'].size).to eq(2)
    end
  end

  describe 'GET /api/v1/admin/categories/:id' do
    let!(:category) { create(:category, store: store) }

    it 'returns category details' do
      get "/api/v1/admin/categories/#{category.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(category.id)
    end
  end

  describe 'POST /api/v1/admin/categories' do
    it 'creates a category (owner)' do
      post '/api/v1/admin/categories',
           params: { category: { name: 'New Category', description: 'Test' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('New Category')
    end

    it 'staff cannot create categories' do
      staff_headers = auth_headers_for(staff_user)
      post '/api/v1/admin/categories',
           params: { category: { name: 'New Category' } },
           headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it 'returns validation errors' do
      post '/api/v1/admin/categories',
           params: { category: { name: nil } },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/admin/categories/:id' do
    let!(:category) { create(:category, store: store) }

    it 'updates a category' do
      patch "/api/v1/admin/categories/#{category.id}",
            params: { category: { name: 'Updated' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq('Updated')
    end
  end

  describe 'DELETE /api/v1/admin/categories/:id' do
    let!(:category) { create(:category, store: store) }

    it 'soft deletes a category' do
      delete "/api/v1/admin/categories/#{category.id}", headers: headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect(category.reload.discarded?).to be true
    end

    it 'staff cannot delete categories' do
      staff_headers = auth_headers_for(staff_user)
      delete "/api/v1/admin/categories/#{category.id}", headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
