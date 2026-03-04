require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Products', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let(:admin_user) { create(:user, :admin, store: store, password: 'password123') }
  let(:staff_user) { create(:user, :staff, store: store, password: 'password123') }
  let(:category) { create(:category, store: store) }
  let!(:headers) { auth_headers_for(owner) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/products' do
    let!(:product1) { create(:product, :active, store: store, name: 'Widget A') }
    let!(:product2) { create(:product, store: store, name: 'Widget B', status: 'draft') }

    it 'returns paginated products' do
      get '/api/v1/admin/products', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['products'].size).to eq(2)
      expect(json_response['meta']).to include('current_page', 'total_count')
    end

    it 'filters by status' do
      get '/api/v1/admin/products', params: { status: 'active' }, headers: headers

      expect(response).to have_http_status(:ok)
      names = json_response['products'].map { |p| p['name'] }
      expect(names).to include('Widget A')
      expect(names).not_to include('Widget B')
    end

    it 'searches by name' do
      get '/api/v1/admin/products', params: { q: 'Widget A' }, headers: headers

      expect(json_response['products'].size).to eq(1)
    end

    it 'filters by category' do
      product1.update!(category: category)
      get '/api/v1/admin/products', params: { category_id: category.id }, headers: headers

      expect(json_response['products'].size).to eq(1)
    end

    it 'requires authentication' do
      get '/api/v1/admin/products', as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns bad_request for missing params key' do
      post '/api/v1/admin/products',
           params: { wrong_key: { name: 'Test' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /api/v1/admin/products/:id' do
    let!(:product) { create(:product, :active, :with_variants, store: store) }

    it 'returns product with details' do
      get "/api/v1/admin/products/#{product.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(product.id)
      expect(json_response['variants']).to be_present
    end

    it 'returns 404 for non-existent product' do
      get "/api/v1/admin/products/#{SecureRandom.uuid}", headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/admin/products' do
    let(:valid_params) do
      {
        product: {
          name: 'New Product',
          description: 'A great product',
          base_price_cents: 2999,
          status: 'active',
          category_id: category.id,
          sku: 'NP-001'
        }
      }
    end

    it 'creates a product' do
      post '/api/v1/admin/products', params: valid_params, headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('New Product')
      expect(json_response['base_price']['amount']).to eq(29.99)
    end

    it 'returns validation errors' do
      post '/api/v1/admin/products',
           params: { product: { name: nil } },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'staff can create products' do
      staff_headers = auth_headers_for(staff_user)
      post '/api/v1/admin/products', params: valid_params, headers: staff_headers, as: :json

      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH /api/v1/admin/products/:id' do
    let!(:product) { create(:product, store: store) }

    it 'updates a product' do
      patch "/api/v1/admin/products/#{product.id}",
            params: { product: { name: 'Updated Name' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq('Updated Name')
    end
  end

  describe 'DELETE /api/v1/admin/products/:id' do
    let!(:product) { create(:product, store: store) }

    it 'soft deletes a product (owner)' do
      delete "/api/v1/admin/products/#{product.id}", headers: headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect(product.reload.discarded?).to be true
    end

    it 'staff cannot delete products' do
      staff_headers = auth_headers_for(staff_user)
      delete "/api/v1/admin/products/#{product.id}", headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
