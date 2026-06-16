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
      expect(json_response['order_number']).to be_present
      expect(json_response['email']).to eq('buyer@test.com')
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
    let(:customer) { create(:customer, store: store) }
    let(:customer_token) do
      JWT.encode(
        { customer_id: customer.id, exp: 24.hours.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )
    end
    let(:customer_headers) { headers.merge('X-Customer-Token' => customer_token) }
    let!(:order) { create(:order, store: store, order_number: '#1001', customer: customer) }

    it 'returns order by order number for authenticated customer' do
      get '/api/v1/storefront/orders/1001', headers: customer_headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['order_number']).to eq('#1001')
    end

    it 'returns 401 without customer authentication' do
      get '/api/v1/storefront/orders/1001', headers: headers, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 404 when order belongs to another customer' do
      other_customer = create(:customer, store: store)
      other_token = JWT.encode(
        { customer_id: other_customer.id, exp: 24.hours.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )
      get '/api/v1/storefront/orders/1001',
          headers: headers.merge('X-Customer-Token' => other_token), as: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for non-existent order' do
      get '/api/v1/storefront/orders/9999', headers: customer_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    context 'with session_id (guest access)' do
      let!(:guest_order) do
        create(:order, store: store, order_number: '#2001',
               customer: nil, stripe_session_id: 'cs_test_guest_123')
      end

      it 'returns order when session_id matches' do
        get '/api/v1/storefront/orders/2001',
            params: { session_id: 'cs_test_guest_123' },
            headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['order_number']).to eq('#2001')
      end

      it 'returns 404 when session_id does not match the order' do
        get '/api/v1/storefront/orders/2001',
            params: { session_id: 'cs_test_wrong_session' },
            headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns 401 without session_id or customer token' do
        get '/api/v1/storefront/orders/2001',
            headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it 'prevents IDOR - session_id from a different order cannot access this order' do
        create(:order, store: store, order_number: '#2002',
               customer: nil, stripe_session_id: 'cs_test_other_456')

        get '/api/v1/storefront/orders/2001',
            params: { session_id: 'cs_test_other_456' },
            headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
