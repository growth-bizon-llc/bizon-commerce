class OrderSerializer
  include Alba::Resource

  attributes :id, :order_number, :email, :status,
             :shipping_address, :billing_address, :notes, :metadata,
             :placed_at, :paid_at, :shipped_at, :delivered_at,
             :cancelled_at, :created_at, :updated_at

  attribute :subtotal do |order|
    { amount: order.subtotal.to_f, currency: order.subtotal_currency }
  end

  attribute :tax do |order|
    { amount: order.tax.to_f, currency: order.tax_currency }
  end

  attribute :total do |order|
    { amount: order.total.to_f, currency: order.total_currency }
  end

  attribute :customer do |order|
    next nil unless order.customer
    { id: order.customer_id, email: order.customer.email,
      first_name: order.customer.first_name, last_name: order.customer.last_name }
  end

  has_many :order_items, key: :items, serializer: OrderItemSerializer
end
