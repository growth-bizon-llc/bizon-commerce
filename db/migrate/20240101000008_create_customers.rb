class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :password_digest
      t.boolean :accepts_marketing, default: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :customers, [:store_id, :email], unique: true
  end
end
