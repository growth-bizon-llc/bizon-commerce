class CleanupOrphanedOrdersJob < ApplicationJob
  queue_as :default

  def perform
    Order.unscoped
         .where(status: %w[pending confirmed])
         .where(created_at: ...24.hours.ago)
         .find_each do |order|
      order.cancel! if order.may_cancel?
    rescue AASM::InvalidTransition => e
      Rails.logger.warn("CleanupOrphanedOrdersJob: Could not cancel order #{order.id}: #{e.message}")
    end
  end
end
