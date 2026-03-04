class CartItem < ApplicationRecord
  monetize :unit_price_cents

  belongs_to :cart
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  def total
    unit_price_cents * quantity
  end
end
