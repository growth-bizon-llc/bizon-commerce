class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, null: true, foreign_key: { to_table: :categories }, type: :uuid
      t.integer :position, default: 0
      t.boolean :active, default: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :categories, [:store_id, :slug], unique: true
    add_index :categories, :discarded_at
  end
end
