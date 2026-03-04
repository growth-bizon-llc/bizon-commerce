module Orders
  class UpdateStatusService < BaseService
    VALID_EVENTS = %w[confirm pay process_order ship deliver cancel refund].freeze

    def initialize(order:, event:)
      super()
      @order = order
      @event = event
    end

    def call
      unless VALID_EVENTS.include?(@event)
        @errors << "Invalid status transition: #{@event}"
        return self
      end

      unless @order.aasm.may_fire_event?(@event.to_sym)
        @errors << "Cannot transition from #{@order.status} via #{@event}"
        return self
      end

      @order.aasm.fire!(@event.to_sym)
      @result = @order
      self
    rescue AASM::InvalidTransition => e
      @errors << e.message
      self
    end
  end
end
