class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :customer, null: true, foreign_key: true, type: :uuid
      t.string :order_number, null: false
      t.string :email, null: false
      t.string :status, null: false, default: 'pending'
      t.integer :subtotal_cents, null: false, default: 0
      t.string :subtotal_currency, default: 'USD'
      t.integer :tax_cents, null: false, default: 0
      t.string :tax_currency, default: 'USD'
      t.integer :total_cents, null: false, default: 0
      t.string :total_currency, default: 'USD'
      t.jsonb :shipping_address, default: {}
      t.jsonb :billing_address, default: {}
      t.text :notes
      t.jsonb :metadata, default: {}
      t.datetime :placed_at
      t.datetime :paid_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, [:store_id, :status]
  end
end
