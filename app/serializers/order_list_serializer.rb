class OrderListSerializer
  include Alba::Resource

  attributes :id, :order_number, :email, :status, :created_at

  attribute :total do |order|
    { amount: order.total.to_f, currency: order.total_currency }
  end

  attribute :items_count do |order|
    order.order_items.size
  end

  attribute :customer_name do |order|
    next nil unless order.customer
    "#{order.customer.first_name} #{order.customer.last_name}".strip
  end
end
