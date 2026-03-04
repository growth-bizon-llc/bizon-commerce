class CartSerializer
  include Alba::Resource

  attributes :id, :token, :status, :metadata, :expires_at,
             :created_at, :updated_at

  attribute :total do |cart|
    currency = cart.cart_items.first&.unit_price_currency || 'USD'
    { amount: (cart.total / 100.0), currency: currency }
  end

  attribute :items_count do |cart|
    cart.items_count
  end

  has_many :cart_items, key: :items, serializer: CartItemSerializer
end
