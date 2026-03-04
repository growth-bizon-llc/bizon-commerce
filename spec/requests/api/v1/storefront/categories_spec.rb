require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Categories', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }

  before { Current.store = store }

  describe 'GET /api/v1/storefront/categories' do
    let!(:cat1) { create(:category, store: store, active: true) }
    let!(:cat2) { create(:category, store: store, active: true) }
    let!(:inactive_cat) { create(:category, store: store, active: false) }
    let!(:child_cat) { create(:category, store: store, parent: cat1, active: true) }

    it 'returns active root categories' do
      get '/api/v1/storefront/categories', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      ids = json_response['categories'].map { |c| c['id'] }
      expect(ids).to include(cat1.id, cat2.id)
      expect(ids).not_to include(child_cat.id)
    end
  end

  describe 'GET /api/v1/storefront/categories/:slug' do
    let!(:category) { create(:category, store: store, active: true) }
    let!(:product) { create(:product, :active, store: store, category: category) }

    it 'returns category with products' do
      get "/api/v1/storefront/categories/#{category.slug}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['category']['id']).to eq(category.id)
      expect(json_response['products']).to be_present
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
