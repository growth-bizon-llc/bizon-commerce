class AddUniqueSkuIndexes < ActiveRecord::Migration[8.1]
  def up
    # Deduplicate product variant SKUs within each store by appending a suffix
    execute <<~SQL
      UPDATE product_variants pv
      SET sku = pv.sku || '-' || pv.id::text
      WHERE pv.id IN (
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (PARTITION BY store_id, sku ORDER BY created_at ASC) AS rn
          FROM product_variants
          WHERE sku IS NOT NULL
        ) dupes
        WHERE rn > 1
      )
    SQL

    remove_index :products, :sku, name: "index_products_on_sku", if_exists: true
    add_index :products, [:store_id, :sku], unique: true, where: "sku IS NOT NULL", name: "index_products_on_store_id_and_sku_unique"

    remove_index :product_variants, :sku, name: "index_product_variants_on_sku", if_exists: true
    add_index :product_variants, [:store_id, :sku], unique: true, where: "sku IS NOT NULL", name: "index_product_variants_on_store_id_and_sku_unique"
  end

  def down
    remove_index :products, name: "index_products_on_store_id_and_sku_unique", if_exists: true
    add_index :products, :sku, name: "index_products_on_sku"

    remove_index :product_variants, name: "index_product_variants_on_store_id_and_sku_unique", if_exists: true
    add_index :product_variants, :sku, name: "index_product_variants_on_sku"
  end
end
