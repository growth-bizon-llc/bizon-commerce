class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items, id: :uuid do |t|
      t.references :cart, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :product_variant, null: true, foreign_key: true, type: :uuid
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.string :unit_price_currency, null: false, default: 'USD'

      t.timestamps
    end
  end
end
