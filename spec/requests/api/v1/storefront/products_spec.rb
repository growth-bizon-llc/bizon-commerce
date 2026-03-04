require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Products', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }

  before { Current.store = store }

  describe 'GET /api/v1/storefront/products' do
    let!(:active_prod) { create(:product, :active, store: store, name: 'Active Widget') }
    let!(:draft_prod) { create(:product, store: store, name: 'Draft Widget', status: 'draft') }
    let!(:featured_prod) { create(:product, :active, :featured, store: store, name: 'Featured Widget') }

    it 'returns only active products' do
      get '/api/v1/storefront/products', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      names = json_response['products'].map { |p| p['name'] }
      expect(names).to include('Active Widget', 'Featured Widget')
      expect(names).not_to include('Draft Widget')
    end

    it 'filters by featured' do
      get '/api/v1/storefront/products', params: { featured: 'true' }, headers: headers

      expect(json_response['products'].size).to eq(1)
      expect(json_response['products'].first['name']).to eq('Featured Widget')
    end

    it 'searches by name' do
      get '/api/v1/storefront/products', params: { q: 'Active' }, headers: headers

      expect(json_response['products'].size).to eq(1)
    end

    it 'returns pagination meta' do
      get '/api/v1/storefront/products', headers: headers, as: :json

      expect(json_response['meta']).to include('current_page', 'total_count')
    end

    it 'returns 404 without store header' do
      get '/api/v1/storefront/products', as: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'resolves store from Origin header' do
      origin_headers = { 'Origin' => "https://#{store.subdomain}" }
      get '/api/v1/storefront/products', headers: origin_headers, as: :json
      expect(response).to have_http_status(:ok)
    end

    it 'handles invalid Origin URI gracefully' do
      origin_headers = { 'Origin' => ':::invalid' }
      get '/api/v1/storefront/products', headers: origin_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/storefront/products/:slug' do
    let!(:product) { create(:product, :active, :with_variants, store: store) }

    it 'returns product by slug' do
      get "/api/v1/storefront/products/#{product.slug}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq(product.name)
      expect(json_response['variants']).to be_present
    end

    it 'returns 404 for non-existent slug' do
      get '/api/v1/storefront/products/nonexistent', headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for draft product' do
      draft = create(:product, store: store, status: 'draft')
      get "/api/v1/storefront/products/#{draft.slug}", headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
