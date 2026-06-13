class CleanupOrphanedOrdersJob < ApplicationJob
  queue_as :default

  def perform
    orders = Order.unscoped
                  .where(status: %w[pending confirmed])
                  .where(payment_status: %w[pending failed])
                  .where(created_at: ...48.hours.ago)

    Rails.logger.info("CleanupOrphanedOrdersJob: Found #{orders.count} orphaned orders to cancel")

    orders.find_each do |order|
      order.cancel! if order.may_cancel?
      Rails.logger.info("CleanupOrphanedOrdersJob: Cancelled order #{order.id} (#{order.order_number})")
    rescue AASM::InvalidTransition => e
      Rails.logger.warn("CleanupOrphanedOrdersJob: Could not cancel order #{order.id}: #{e.message}")
    end
  end
end
