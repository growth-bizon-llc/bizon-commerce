class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :custom_domain
      t.string :subdomain
      t.text :description
      t.string :currency, default: 'USD'
      t.string :locale, default: 'en'
      t.jsonb :settings, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :stores, :slug, unique: true
    add_index :stores, :custom_domain, unique: true
    add_index :stores, :subdomain, unique: true
  end
end
