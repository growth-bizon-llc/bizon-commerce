class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :product_variant, null: true, foreign_key: true, type: :uuid
      t.string :product_name, null: false
      t.string :variant_name
      t.string :sku
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.string :unit_price_currency, default: 'USD'
      t.integer :total_cents, null: false
      t.string :total_currency, default: 'USD'

      t.timestamps
    end
  end
end
