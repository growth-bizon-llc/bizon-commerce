require 'rails_helper'

RSpec.describe 'Webhooks::Stripe', type: :request do
  let(:store) { create(:store) }
  let(:webhook_secret) { 'whsec_test_secret' }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('STRIPE_WEBHOOK_SECRET').and_return(webhook_secret)
  end

  def stripe_event(type, data_object)
    payload = {
      id: "evt_#{SecureRandom.hex(8)}",
      type: type,
      data: { object: data_object }
    }.to_json

    timestamp = Time.now
    signature = Stripe::Webhook::Signature.compute_signature(timestamp, payload, webhook_secret)
    sig_header = "t=#{timestamp.to_i},v1=#{signature}"

    [payload, sig_header]
  end

  describe 'POST /webhooks/stripe' do
    context 'checkout.session.completed' do
      let(:order) { create(:order, store: store, payment_status: 'pending') }

      it 'marks order as paid and transitions to paid status' do
        payload, sig_header = stripe_event('checkout.session.completed', {
          id: 'cs_test_123',
          payment_intent: 'pi_test_456',
          metadata: { order_id: order.id, store_id: store.id }
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)

        order.reload
        expect(order.stripe_session_id).to eq('cs_test_123')
        expect(order.stripe_payment_intent_id).to eq('pi_test_456')
        expect(order.payment_status).to eq('paid')
        expect(order.status).to eq('paid')
        expect(order.paid_at).to be_present
      end

      it 'is idempotent - skips if already paid' do
        order.update!(payment_status: 'paid', status: 'paid', paid_at: 1.hour.ago)

        payload, sig_header = stripe_event('checkout.session.completed', {
          id: 'cs_test_123',
          payment_intent: 'pi_test_456',
          metadata: { order_id: order.id }
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
      end

      it 'skips checkout completed for cancelled orders' do
        order.update!(status: 'cancelled', cancelled_at: 1.hour.ago)

        payload, sig_header = stripe_event('checkout.session.completed', {
          id: 'cs_test_123',
          payment_intent: 'pi_test_456',
          metadata: { order_id: order.id, store_id: store.id }
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq('cancelled')
        expect(order.reload.payment_status).to eq('pending')
      end

      it 'handles missing order gracefully' do
        payload, sig_header = stripe_event('checkout.session.completed', {
          id: 'cs_test_123',
          payment_intent: 'pi_test_456',
          metadata: { order_id: SecureRandom.uuid }
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'checkout.session.expired' do
      let(:order) { create(:order, store: store, payment_status: 'pending') }

      it 'cancels the order' do
        payload, sig_header = stripe_event('checkout.session.expired', {
          id: 'cs_test_expired',
          metadata: { order_id: order.id }
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq('cancelled')
      end
    end

    context 'payment_intent.payment_failed' do
      let!(:order) { create(:order, store: store, stripe_payment_intent_id: 'pi_test_fail') }

      it 'updates payment_status to failed' do
        payload, sig_header = stripe_event('payment_intent.payment_failed', {
          id: 'pi_test_fail'
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
        expect(order.reload.payment_status).to eq('failed')
      end

      it 'is idempotent when payment already failed' do
        order.update!(payment_status: 'failed')

        payload, sig_header = stripe_event('payment_intent.payment_failed', {
          id: 'pi_test_fail'
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
        expect(order.reload.payment_status).to eq('failed')
      end
    end

    context 'charge.refunded' do
      let!(:order) { create(:order, :paid, store: store, stripe_payment_intent_id: 'pi_test_refund') }

      it 'marks order as refunded' do
        payload, sig_header = stripe_event('charge.refunded', {
          id: 'ch_test_123',
          payment_intent: 'pi_test_refund'
        })

        post '/webhooks/stripe',
             params: payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:ok)
        order.reload
        expect(order.payment_status).to eq('refunded')
        expect(order.status).to eq('refunded')
      end
    end

    context 'invalid signature' do
      it 'returns 400' do
        post '/webhooks/stripe',
             params: { type: 'test' }.to_json,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => 'invalid',
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'invalid JSON' do
      it 'returns 400' do
        timestamp = Time.now
        bad_payload = 'not json'
        signature = Stripe::Webhook::Signature.compute_signature(timestamp, bad_payload, webhook_secret)
        sig_header = "t=#{timestamp.to_i},v1=#{signature}"

        post '/webhooks/stripe',
             params: bad_payload,
             headers: {
               'HTTP_STRIPE_SIGNATURE' => sig_header,
               'CONTENT_TYPE' => 'application/json'
             }

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
