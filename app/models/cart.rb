class Cart < ApplicationRecord
  include Multi::Scoped

  belongs_to :customer, optional: true
  has_many :cart_items, dependent: :destroy

  validates :token, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active abandoned converted] }

  before_validation :generate_token, on: :create

  scope :active, -> { where(status: 'active') }
  scope :abandoned, -> { where(status: 'abandoned') }

  def total
    cart_items.sum('unit_price_cents * quantity')
  end

  def items_count
    cart_items.sum(:quantity)
  end

  def add_item(product, variant = nil, quantity = 1)
    existing = cart_items.find_by(product: product, product_variant: variant)
    if existing
      existing.update!(quantity: existing.quantity + quantity)
      existing
    else
      price = variant&.price_cents || product.base_price_cents
      currency = variant&.price_currency || product.base_price_currency
      cart_items.create!(
        product: product,
        product_variant: variant,
        quantity: quantity,
        unit_price_cents: price,
        unit_price_currency: currency
      )
    end
  end

  def remove_item(cart_item_id)
    cart_items.find(cart_item_id).destroy!
  end

  def clear!
    cart_items.destroy_all
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32) if token.blank?
  end
end
