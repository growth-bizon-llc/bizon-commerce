class ProductVariant < ApplicationRecord
  include Multi::Scoped
  include Discard::Model
  include Sanitizable

  monetize :price_cents
  monetize :compare_at_price_cents, allow_nil: true

  belongs_to :product

  sanitize_fields :name

  validates :name, presence: true, length: { maximum: 255 }
  validates :sku, uniqueness: { scope: :store_id }, allow_blank: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :compare_at_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  default_scope -> { kept }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }
end
