class CreateProductVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :product_variants, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :sku
      t.integer :price_cents, null: false, default: 0
      t.string :price_currency, null: false, default: 'USD'
      t.integer :compare_at_price_cents
      t.string :compare_at_price_currency, default: 'USD'
      t.boolean :track_inventory, default: true
      t.integer :quantity, default: 0
      t.jsonb :options, default: {}
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :product_variants, :sku
    add_index :product_variants, :discarded_at
  end
end
