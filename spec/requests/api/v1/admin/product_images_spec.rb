require 'rails_helper'

RSpec.describe 'Api::V1::Admin::ProductImages', type: :request do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store, password: 'password123') }
  let(:staff_user) { create(:user, :staff, store: store, password: 'password123') }
  let!(:headers) { auth_headers_for(owner) }
  let!(:product) { create(:product, store: store) }

  before { Current.store = store }

  describe 'GET /api/v1/admin/products/:product_id/images' do
    let!(:image) { create(:product_image, product: product, store: store, position: 0) }

    it 'returns product images' do
      get "/api/v1/admin/products/#{product.id}/images", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['images'].size).to eq(1)
    end
  end

  describe 'POST /api/v1/admin/products/:product_id/images' do
    it 'creates an image' do
      image_file = Rack::Test::UploadedFile.new(
        StringIO.new("\x89PNG\r\n\x1a\n" + "\x00" * 100),
        'image/png',
        true,
        original_filename: 'test.png'
      )

      post "/api/v1/admin/products/#{product.id}/images",
           params: { image: image_file, position: 0, alt_text: 'Product photo' },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json_response['alt_text']).to eq('Product photo')
    end

    it 'returns error without image file' do
      post "/api/v1/admin/products/#{product.id}/images",
           params: { position: 0, alt_text: 'No image' },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['error']).to eq('Image file is required')
    end
  end

  describe 'PATCH /api/v1/admin/products/:product_id/images/:id' do
    let!(:image) { create(:product_image, product: product, store: store) }

    it 'updates image attributes' do
      patch "/api/v1/admin/products/#{product.id}/images/#{image.id}",
            params: { position: 5, alt_text: 'Updated alt' },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['alt_text']).to eq('Updated alt')
    end
  end

  describe 'DELETE /api/v1/admin/products/:product_id/images/:id' do
    let!(:image) { create(:product_image, product: product, store: store) }

    it 'deletes the image' do
      delete "/api/v1/admin/products/#{product.id}/images/#{image.id}",
             headers: headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect(ProductImage.find_by(id: image.id)).to be_nil
    end

    it 'staff cannot delete images' do
      staff_headers = auth_headers_for(staff_user)
      delete "/api/v1/admin/products/#{product.id}/images/#{image.id}",
             headers: staff_headers, as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
