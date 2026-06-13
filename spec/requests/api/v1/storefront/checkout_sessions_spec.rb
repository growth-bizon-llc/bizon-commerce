require 'rails_helper'

RSpec.describe 'Api::V1::Storefront::CheckoutSessions', type: :request do
  let(:store) { create(:store, tax_rate: 10.0) }
  let(:headers) { storefront_headers_for(store) }
  let(:product) { create(:product, :active, store: store, base_price_cents: 2500) }

  before { Current.store = store }

  describe 'POST /api/v1/storefront/checkout/sessions' do
    let(:cart) { create(:cart, store: store) }

    before do
      create(:cart_item, cart: cart, product: product, unit_price_cents: 2500, quantity: 2)
    end

    let(:stripe_session) do
      double(
        'Stripe::Checkout::Session',
        id: 'cs_test_123',
        client_secret: 'cs_test_secret_456'
      )
    end

    before do
      allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_session)
    end

    let(:valid_params) do
      {
        email: 'buyer@test.com',
        terms_accepted: true,
        shipping_address: { address1: '123 Main St', city: 'NY', state: 'NY', zip: '10001' },
        return_url: 'https://store.example.com/checkout/complete?session_id={CHECKOUT_SESSION_ID}'
      }
    end

    it 'creates a checkout session and order' do
      post '/api/v1/storefront/checkout/sessions',
           params: valid_params,
           headers: headers.merge('X-Cart-Token' => cart.token),
           as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['client_secret']).to eq('cs_test_secret_456')
      expect(body['order_number']).to be_present
    end

    it 'stores stripe_session_id on the order' do
      post '/api/v1/storefront/checkout/sessions',
           params: { email: 'buyer@test.com', terms_accepted: true },
           headers: headers.merge('X-Cart-Token' => cart.token),
           as: :json

      order = Order.unscoped.last
      expect(order.stripe_session_id).to eq('cs_test_123')
    end

    it 'passes correct line items to Stripe' do
      post '/api/v1/storefront/checkout/sessions',
           params: { email: 'buyer@test.com', terms_accepted: true },
           headers: headers.merge('X-Cart-Token' => cart.token),
           as: :json

      expect(Stripe::Checkout::Session).to have_received(:create).with(
        hash_including(
          ui_mode: 'embedded',
          mode: 'payment',
          customer_email: 'buyer@test.com',
          metadata: hash_including(order_id: anything, store_id: store.id)
        ),
        hash_including(idempotency_key: anything)
      )
    end

    it 'fails with empty cart' do
      empty_cart = create(:cart, store: store)

      post '/api/v1/storefront/checkout/sessions',
           params: { email: 'test@test.com', terms_accepted: true },
           headers: headers.merge('X-Cart-Token' => empty_cart.token),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'fails without cart token' do
      post '/api/v1/storefront/checkout/sessions',
           params: { email: 'test@test.com' },
           headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it 'converts cart to converted status' do
      post '/api/v1/storefront/checkout/sessions',
           params: { email: 'buyer@test.com', terms_accepted: true },
           headers: headers.merge('X-Cart-Token' => cart.token),
           as: :json

      expect(cart.reload.status).to eq('converted')
    end

    context 'terms acceptance' do
      it 'rejects checkout without terms_accepted' do
        params_without_terms = valid_params.except(:terms_accepted)
        post '/api/v1/storefront/checkout/sessions',
             params: params_without_terms,
             headers: headers.merge('X-Cart-Token' => cart.token),
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body['errors']).to include('You must accept the terms and conditions')
      end
    end
  end

  describe 'GET /api/v1/storefront/checkout/sessions/:id/status' do
    let(:stripe_session) do
      double(
        'Stripe::Checkout::Session',
        status: 'complete',
        payment_status: 'paid',
        customer_details: double(email: 'buyer@test.com')
      )
    end

    before do
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(stripe_session)
    end

    it 'returns session status' do
      order = create(:order, store: store, stripe_session_id: 'cs_test_123')

      get '/api/v1/storefront/checkout/sessions/cs_test_123/status',
          headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['status']).to eq('complete')
      expect(body['payment_status']).to eq('paid')
      expect(body['customer_email']).to eq('buyer@test.com')
    end

    it 'returns 404 for unknown session' do
      get '/api/v1/storefront/checkout/sessions/cs_unknown/status',
          headers: headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
