class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :category, null: true, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :short_description
      t.integer :base_price_cents, null: false, default: 0
      t.string :base_price_currency, null: false, default: 'USD'
      t.integer :compare_at_price_cents
      t.string :compare_at_price_currency, default: 'USD'
      t.string :sku
      t.string :barcode
      t.boolean :track_inventory, default: true
      t.integer :quantity, default: 0
      t.jsonb :custom_attributes, default: {}
      t.string :status, null: false, default: 'draft'
      t.boolean :featured, default: false
      t.integer :position, default: 0
      t.datetime :published_at
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :products, [:store_id, :slug], unique: true
    add_index :products, :sku
    add_index :products, :discarded_at
    add_index :products, [:store_id, :status]
    add_index :products, [:store_id, :featured]
  end
end
