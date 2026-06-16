class Order < ApplicationRecord
  include Multi::Scoped
  include AASM

  monetize :subtotal_cents
  monetize :tax_cents
  monetize :total_cents
  monetize :refund_amount_cents, allow_nil: true

  belongs_to :customer, optional: true
  has_many :order_items, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subtotal_cents, :tax_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :refund_amount_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :payment_status, inclusion: { in: %w[pending paid failed refunded] }

  before_validation :generate_order_number, on: :create

  aasm column: :status do
    state :pending, initial: true
    state :confirmed
    state :paid
    state :processing
    state :shipped
    state :delivered
    state :cancelled
    state :refunded

    event :confirm do
      transitions from: :pending, to: :confirmed
    end

    event :pay do
      before do
        self.paid_at = Time.current
      end
      transitions from: :confirmed, to: :paid
    end

    event :process_order do
      transitions from: :paid, to: :processing
    end

    event :ship do
      before do
        self.shipped_at = Time.current
      end
      transitions from: :processing, to: :shipped
    end

    event :deliver do
      before do
        self.delivered_at = Time.current
      end
      transitions from: :shipped, to: :delivered
    end

    event :cancel do
      before do
        self.cancelled_at = Time.current
        restore_inventory!
      end
      transitions from: [:pending, :confirmed], to: :cancelled
    end

    event :refund do
      before do
        self.refunded_at = Time.current
        restore_inventory!
      end
      transitions from: :paid, to: :refunded
    end
  end

  scope :by_status, ->(status) { where(status: status) }

  def payment_paid?
    payment_status == 'paid'
  end

  private

  def restore_inventory!
    order_items.each do |item|
      variant = item.product_variant_id ? ProductVariant.unscoped.find_by(id: item.product_variant_id) : nil
      product = Product.unscoped.find_by(id: item.product_id)
      next unless product

      if variant && !variant.discarded? && variant.track_inventory
        variant.with_lock do
          variant.update!(quantity: variant.quantity + item.quantity)
        end
      elsif !variant && !product.discarded? && product.track_inventory
        product.with_lock do
          product.update!(quantity: product.quantity + item.quantity)
        end
      end
    end
  end

  def generate_order_number
    return if order_number.present?

    loop do
      self.order_number = "#BZ-#{SecureRandom.alphanumeric(8).upcase}"
      break unless Order.unscoped.exists?(order_number: order_number)
    end
  end
end
