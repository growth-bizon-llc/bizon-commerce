# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_04_041732) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cart_id", null: false
    t.datetime "created_at", null: false
    t.uuid "product_id", null: false
    t.uuid "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", null: false
    t.string "unit_price_currency", default: "USD", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["product_variant_id"], name: "index_cart_items_on_product_variant_id"
  end

  create_table "carts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "customer_id"
    t.datetime "expires_at"
    t.jsonb "metadata", default: {}
    t.string "status", default: "active"
    t.uuid "store_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_carts_on_customer_id"
    t.index ["store_id"], name: "index_carts_on_store_id"
    t.index ["token"], name: "index_carts_on_token", unique: true
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.uuid "parent_id"
    t.integer "position", default: 0
    t.string "slug", null: false
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_categories_on_discarded_at"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["store_id", "slug"], name: "index_categories_on_store_id_and_slug", unique: true
    t.index ["store_id"], name: "index_categories_on_store_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "accepts_marketing", default: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.jsonb "metadata", default: {}
    t.string "password_digest"
    t.string "phone"
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "email"], name: "index_customers_on_store_id_and_email", unique: true
    t.index ["store_id"], name: "index_customers_on_store_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "order_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "order_id", null: false
    t.uuid "product_id", null: false
    t.string "product_name", null: false
    t.uuid "product_variant_id"
    t.integer "quantity", default: 1, null: false
    t.string "sku"
    t.integer "total_cents", null: false
    t.string "total_currency", default: "USD"
    t.integer "unit_price_cents", null: false
    t.string "unit_price_currency", default: "USD"
    t.datetime "updated_at", null: false
    t.string "variant_name"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "billing_address", default: {}
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.uuid "customer_id"
    t.datetime "delivered_at"
    t.string "email", null: false
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.string "order_number", null: false
    t.datetime "paid_at"
    t.datetime "placed_at"
    t.datetime "shipped_at"
    t.jsonb "shipping_address", default: {}
    t.string "status", default: "pending", null: false
    t.uuid "store_id", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.string "subtotal_currency", default: "USD"
    t.integer "tax_cents", default: 0, null: false
    t.string "tax_currency", default: "USD"
    t.integer "total_cents", default: 0, null: false
    t.string "total_currency", default: "USD"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["store_id", "status"], name: "index_orders_on_store_id_and_status"
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "product_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.uuid "product_id", null: false
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
    t.index ["store_id"], name: "index_product_images_on_store_id"
  end

  create_table "product_variants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "compare_at_price_cents"
    t.string "compare_at_price_currency", default: "USD"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "name", null: false
    t.jsonb "options", default: {}
    t.integer "position", default: 0
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.uuid "product_id", null: false
    t.integer "quantity", default: 0
    t.string "sku"
    t.uuid "store_id", null: false
    t.boolean "track_inventory", default: true
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_product_variants_on_discarded_at"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku"
    t.index ["store_id"], name: "index_product_variants_on_store_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "barcode"
    t.integer "base_price_cents", default: 0, null: false
    t.string "base_price_currency", default: "USD", null: false
    t.uuid "category_id"
    t.integer "compare_at_price_cents"
    t.string "compare_at_price_currency", default: "USD"
    t.datetime "created_at", null: false
    t.jsonb "custom_attributes", default: {}
    t.text "description"
    t.datetime "discarded_at"
    t.boolean "featured", default: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "published_at"
    t.integer "quantity", default: 0
    t.string "short_description"
    t.string "sku"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.uuid "store_id", null: false
    t.boolean "track_inventory", default: true
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["sku"], name: "index_products_on_sku"
    t.index ["store_id", "featured"], name: "index_products_on_store_id_and_featured"
    t.index ["store_id", "slug"], name: "index_products_on_store_id_and_slug", unique: true
    t.index ["store_id", "status"], name: "index_products_on_store_id_and_status"
    t.index ["store_id"], name: "index_products_on_store_id"
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.string "custom_domain"
    t.text "description"
    t.string "locale", default: "en"
    t.string "name", null: false
    t.jsonb "settings", default: {}
    t.string "slug", null: false
    t.string "subdomain"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_domain"], name: "index_stores_on_custom_domain", unique: true
    t.index ["slug"], name: "index_stores_on_slug", unique: true
    t.index ["subdomain"], name: "index_stores_on_subdomain", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "first_name", null: false
    t.string "jti", null: false
    t.string "last_name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.uuid "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["store_id"], name: "index_users_on_store_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "customers"
  add_foreign_key "carts", "stores"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories", "stores"
  add_foreign_key "customers", "stores"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "stores"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_images", "stores"
  add_foreign_key "product_variants", "products"
  add_foreign_key "product_variants", "stores"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "stores"
  add_foreign_key "users", "stores"
end
