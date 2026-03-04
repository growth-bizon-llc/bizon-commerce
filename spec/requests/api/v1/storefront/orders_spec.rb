require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::Orders', type: :request do
  let(:store) { create(:store) }
  let(:headers) { storefront_headers_for(store) }
  let(:product) { create(:product, :active, store: store, base_price_cents: 2500) }

  before { Current.store = store }

  describe 'POST /api/v1/storefront/orders' do
    let(:cart) { create(:cart, store: store) }

    before do
      create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 2)
    end

    it 'creates an order from cart' do
      post '/api/v1/storefront/orders',
           params: {
             email: 'buyer@test.com',
             shipping_address: { line1: '123 Main', city: 'NY' }
           },
           headers: headers.merge('X-Cart-Token' => cart.token),
           as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['email']).to eq('buyer@test.com')
      expect(json_response['items'].size).to eq(1)
      expect(json_response['order_number']).to be_present
    end

    it 'creates an order with authenticated customer' do
      customer = create(:customer, store: store, email: 'buyer@test.com')
      token = JWT.encode(
        { customer_id: customer.id, exp: 24.hours.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      post '/api/v1/storefront/orders',
           params: { email: 'buyer@test.com' },
           headers: headers.merge(
             'X-Cart-Token' => cart.token,
             'X-Customer-Token' => token
           ),
           as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['customer']).to be_present
    end

    it 'handles invalid customer token gracefully' do
      post '/api/v1/storefront/orders',
           params: { email: 'buyer@test.com' },
           headers: headers.merge(
             'X-Cart-Token' => cart.token,
             'X-Customer-Token' => 'invalid-token'
           ),
           as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['customer']).to be_nil
    end

    it 'fails with empty cart' do
      empty_cart = create(:cart, store: store)
      post '/api/v1/storefront/orders',
           params: { email: 'test@test.com' },
           headers: headers.merge('X-Cart-Token' => empty_cart.token),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'fails without cart token' do
      post '/api/v1/storefront/orders',
           params: { email: 'test@test.com' },
           headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/storefront/orders/:order_number' do
    let!(:order) { create(:order, store: store, order_number: '#1001') }

    it 'returns order by order number' do
      get '/api/v1/storefront/orders/1001', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['order_number']).to eq('#1001')
    end

    it 'returns 404 for non-existent order' do
      get '/api/v1/storefront/orders/9999', headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
