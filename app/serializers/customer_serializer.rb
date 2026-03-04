class CustomerSerializer
  include Alba::Resource

  attributes :id, :email, :first_name, :last_name, :phone,
             :accepts_marketing, :metadata, :created_at, :updated_at

  attribute :orders_count do |customer|
    customer.orders.size
  end
end
