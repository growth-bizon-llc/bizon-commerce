class OrderItem < ApplicationRecord
  monetize :unit_price_cents
  monetize :total_cents

  belongs_to :order
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }
end
