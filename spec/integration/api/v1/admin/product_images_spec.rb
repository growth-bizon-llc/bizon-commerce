require 'swagger_helper'

RSpec.describe 'Admin Product Images', type: :request do
  # store, user, Authorization, and Current.store are provided by the
  # 'admin_bearer_auth' shared context defined in swagger_helper.rb.

  let(:product) { create(:product, store: store) }

  path '/api/v1/admin/products/{product_id}/images' do
    parameter name: :product_id, in: :path, type: :string, required: true, description: 'Product ID'

    let(:product_id) { product.id }

    get 'List product images' do
      tags 'Admin / Product Images'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Images list' do
        before { create(:product_image, product: product, store: store) }

        schema type: :object, properties: {
          images: {
            type: :array,
            items: { '$ref': '#/components/schemas/product_image' }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end

    post 'Upload product image' do
      tags 'Admin / Product Images'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :image, in: :formData, type: :file, required: true, description: 'Image file'
      parameter name: :position, in: :formData, type: :integer, required: false, description: 'Display position'
      parameter name: :alt_text, in: :formData, type: :string, required: false, description: 'Alt text for accessibility'

      response '201', 'Image uploaded' do
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new('fake image data'), 'image/jpeg', true, original_filename: 'test.jpg') }
        schema '$ref': '#/components/schemas/product_image'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:image) { Rack::Test::UploadedFile.new(StringIO.new('fake image data'), 'image/jpeg', true, original_filename: 'test.jpg') }
        run_test!
      end

      response '422', 'Invalid file' do
        let(:image) { nil }
        run_test!
      end
    end
  end

  path '/api/v1/admin/products/{product_id}/images/{id}' do
    parameter name: :product_id, in: :path, type: :string, required: true, description: 'Product ID'
    parameter name: :id, in: :path, type: :string, required: true, description: 'Image ID'

    let(:product_id) { product.id }
    let(:product_image) { create(:product_image, product: product, store: store) }
    let(:id) { product_image.id }

    patch 'Update image metadata' do
      tags 'Admin / Product Images'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          position: { type: :integer },
          alt_text: { type: :string }
        }
      }

      response '200', 'Image updated' do
        let(:body) { { position: 1, alt_text: 'Updated alt text' } }
        schema '$ref': '#/components/schemas/product_image'
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:body) { { position: 1 } }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        let(:body) { { position: 1 } }
        run_test!
      end
    end

    delete 'Delete image' do
      tags 'Admin / Product Images'
      security [bearer_auth: []]

      response '204', 'Image deleted' do
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end

      response '404', 'Not found' do
        let(:id) { '00000000-0000-0000-0000-000000000000' }
        run_test!
      end
    end
  end
end
