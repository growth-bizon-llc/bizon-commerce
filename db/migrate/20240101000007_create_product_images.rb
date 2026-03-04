class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.integer :position, default: 0
      t.string :alt_text

      t.timestamps
    end
  end
end
