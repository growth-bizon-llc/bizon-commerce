class AddStripeFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :stripe_session_id, :string
    add_column :orders, :stripe_payment_intent_id, :string
    add_column :orders, :payment_status, :string, default: 'pending', null: false

    add_index :orders, :stripe_session_id, unique: true, where: 'stripe_session_id IS NOT NULL'
    add_index :orders, :stripe_payment_intent_id, unique: true, where: 'stripe_payment_intent_id IS NOT NULL'
  end
end
