class AddDeletedAtToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :deleted_at, :datetime
  end
end
