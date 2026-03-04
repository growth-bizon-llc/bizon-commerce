class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :customer, null: true, foreign_key: true, type: :uuid
      t.string :token, null: false
      t.string :status, default: 'active'
      t.jsonb :metadata, default: {}
      t.datetime :expires_at

      t.timestamps
    end

    add_index :carts, :token, unique: true
  end
end
