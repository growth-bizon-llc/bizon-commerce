require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Variants', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }
  let!(:product) { create(:product, store: store) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/products/:product_id/variants' do
    let!(:variant) { create(:product_variant, product: product, store: store) }

    it 'returns product variants' do
      get "/api/v1/admin/products/#{product.id}/variants", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['variants'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/admin/products/:product_id/variants/:id' do
    let!(:variant) { create(:product_variant, product: product, store: store) }

    it 'returns variant details' do
      get "/api/v1/admin/products/#{product.id}/variants/#{variant.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(variant.id)
      expect(json_response['name']).to eq(variant.name)
    end
  end

  describe 'POST /api/v1/admin/products/:product_id/variants' do
    it 'creates a variant' do
      post "/api/v1/admin/products/#{product.id}/variants",
           params: { variant: { name: 'Red / XL', price_cents: 3000, sku: 'RED-XL' } },
           headers: headers, as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('Red / XL')
    end
  end

  describe 'PATCH /api/v1/admin/products/:product_id/variants/:id' do
    let!(:variant) { create(:product_variant, product: product, store: store) }

    it 'updates a variant' do
      patch "/api/v1/admin/products/#{product.id}/variants/#{variant.id}",
            params: { variant: { name: 'Updated' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['name']).to eq('Updated')
    end
  end

  describe 'DELETE /api/v1/admin/products/:product_id/variants/:id' do
    let!(:variant) { create(:product_variant, product: product, store: store) }

    it 'soft deletes a variant' do
      delete "/api/v1/admin/products/#{product.id}/variants/#{variant.id}", headers: headers, as: :json

      expect(response).to have_http_status(:no_content)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
