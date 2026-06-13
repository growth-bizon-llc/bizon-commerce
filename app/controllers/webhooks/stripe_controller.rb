module Webhooks
  class StripeController < ActionController::API
    def create
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, ENV.fetch('STRIPE_WEBHOOK_SECRET')
        )
      rescue JSON::ParserError
        return head :bad_request
      rescue Stripe::SignatureVerificationError
        return head :bad_request
      end

      begin
        handle_event(event)
      rescue ActiveRecord::RecordNotFound, AASM::InvalidTransition => e
        Rails.logger.warn("Stripe webhook permanent error for event #{event.id}: #{e.class} - #{e.message}")
      rescue StandardError => e
        Rails.logger.error("Stripe webhook unexpected error for event #{event.id}: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace&.first(5)&.join("\n"))
      end

      head :ok
    end

    private

    def handle_event(event)
      Rails.logger.info("Processing Stripe webhook: #{event.type} (#{event.id})")
      case event.type
      when 'checkout.session.completed'
        handle_checkout_completed(event.data.object)
      when 'checkout.session.expired'
        handle_checkout_expired(event.data.object)
      when 'payment_intent.payment_failed'
        handle_payment_failed(event.data.object)
      when 'charge.refunded'
        handle_charge_refunded(event.data.object)
      end
    end

    def handle_checkout_completed(session)
      Order.transaction do
        order = Order.unscoped.lock.find_by(id: session.metadata.order_id)
        return unless order
        return if order.paid?
        return if order.cancelled?

        order.update!(
          stripe_session_id: session.id,
          stripe_payment_intent_id: session.payment_intent,
          payment_status: 'paid'
        )

        order.confirm! if order.may_confirm?
        order.pay! if order.may_pay?
        order.save!
      end
    end

    def handle_checkout_expired(session)
      Order.transaction do
        order = Order.unscoped.lock.find_by(id: session.metadata.order_id)
        return unless order

        order.cancel! if order.may_cancel?
        order.save!
      end
    end

    def handle_payment_failed(payment_intent)
      Order.transaction do
        order = Order.unscoped.lock.find_by(stripe_payment_intent_id: payment_intent.id)
        return unless order
        return if order.payment_status == 'failed'

        order.update!(payment_status: 'failed')
      end
    end

    def handle_charge_refunded(charge)
      Order.transaction do
        order = Order.unscoped.lock.find_by(stripe_payment_intent_id: charge.payment_intent)
        return unless order

        order.update!(payment_status: 'refunded')
        order.refund! if order.may_refund?
        order.save!
      end
    end

    def find_order(order_id)
      return nil unless order_id
      Order.unscoped.find_by(id: order_id)
    end
  end
end
