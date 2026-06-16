class AddTermsAcceptedToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :terms_accepted, :boolean
    add_column :orders, :terms_accepted_at, :datetime
  end
end
