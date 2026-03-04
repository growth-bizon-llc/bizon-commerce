require 'swagger_helper'

RSpec.describe 'Admin Product Images', type: :request do
  path '/api/v1/admin/products/{product_id}/images' do
    parameter name: :product_id, in: :path, type: :integer, required: true, description: 'Product ID'

    get 'List product images' do
      tags 'Admin / Product Images'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'Images list' do
        schema type: :object, properties: {
          images: {
            type: :array,
            items: { '$ref': '#/components/schemas/product_image' }
          }
        }
        run_test!
      end

      response '401', 'Unauthorized' do
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
        schema '$ref': '#/components/schemas/product_image'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '422', 'Invalid file' do
        run_test!
      end
    end
  end

  path '/api/v1/admin/products/{product_id}/images/{id}' do
    parameter name: :product_id, in: :path, type: :integer, required: true, description: 'Product ID'
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Image ID'

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
        schema '$ref': '#/components/schemas/product_image'
        run_test!
      end

      response '401', 'Unauthorized' do
        run_test!
      end

      response '404', 'Not found' do
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
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end
  end
end
