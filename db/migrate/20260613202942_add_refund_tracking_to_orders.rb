class AddRefundTrackingToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :refund_amount_cents, :integer, default: 0
    add_column :orders, :refunded_at, :datetime
  end
end
