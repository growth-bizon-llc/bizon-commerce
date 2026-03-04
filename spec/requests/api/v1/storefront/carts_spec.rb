require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Carts', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }
  let(:product) { create(:product, :active, store: store, base_price_cents: 2500, quantity: 10) }

  before { Current.store = store }

  describe 'GET /api/v1/storefront/cart' do
    it 'creates a new cart when no token provided' do
      get '/api/v1/storefront/cart', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['token']).to be_present
      expect(response.headers['X-Cart-Token']).to be_present
    end

    it 'returns existing cart' do
      cart = create(:cart, store: store)
      get '/api/v1/storefront/cart',
          headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(cart.id)
    end
  end

  describe 'POST /api/v1/storefront/cart/add_item' do
    it 'adds product to cart' do
      post '/api/v1/storefront/cart/add_item',
           params: { product_id: product.id, quantity: 2 },
           headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['items'].size).to eq(1)
      expect(json_response['items'].first['quantity']).to eq(2)
    end

    it 'adds product with variant' do
      variant = create(:product_variant, product: product, store: store, price_cents: 3000, quantity: 5)
      post '/api/v1/storefront/cart/add_item',
           params: { product_id: product.id, variant_id: variant.id, quantity: 1 },
           headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['items'].first['variant']).to be_present
    end

    it 'returns error for out of stock' do
      product.update!(quantity: 0)
      post '/api/v1/storefront/cart/add_item',
           params: { product_id: product.id, quantity: 1 },
           headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/storefront/cart/update_item' do
    it 'updates item quantity' do
      cart = create(:cart, store: store)
      item = create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 1)

      patch '/api/v1/storefront/cart/update_item',
            params: { cart_item_id: item.id, quantity: 5 },
            headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:ok)
    end

    it 'returns error for invalid item' do
      cart = create(:cart, store: store)

      patch '/api/v1/storefront/cart/update_item',
            params: { cart_item_id: SecureRandom.uuid, quantity: 5 },
            headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/storefront/cart/remove_item' do
    it 'removes item from cart' do
      cart = create(:cart, store: store)
      item = create(:cart_item, cart: cart, product: product, unit_price_cents: 2500)

      delete '/api/v1/storefront/cart/remove_item',
             params: { cart_item_id: item.id },
             headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['items']).to be_empty
    end

    it 'returns error for missing item' do
      cart = create(:cart, store: store)

      delete '/api/v1/storefront/cart/remove_item',
             params: { cart_item_id: SecureRandom.uuid },
             headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/storefront/cart/clear' do
    it 'clears all items' do
      cart = create(:cart, store: store)
      create(:cart_item, cart: cart, product: product, unit_price_cents: 2500)

      delete '/api/v1/storefront/cart/clear',
             headers: headers.merge('X-Cart-Token' => cart.token), as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['items']).to be_empty
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
