class Product < ApplicationRecord
  include Multi::Scoped
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :store

  monetize :base_price_cents
  monetize :compare_at_price_cents, allow_nil: true

  belongs_to :category, optional: true
  has_many :variants, class_name: 'ProductVariant', dependent: :destroy
  has_many :product_images, dependent: :destroy
  has_many :line_items, class_name: 'OrderItem', dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :base_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :compare_at_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :slug, uniqueness: { scope: :store_id }
  validates :status, inclusion: { in: %w[draft active archived] }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  default_scope -> { kept }
  scope :active, -> { where(status: 'active') }
  scope :draft, -> { where(status: 'draft') }
  scope :archived, -> { where(status: 'archived') }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('quantity > 0 OR track_inventory = ?', false) }
  scope :ordered, -> { order(position: :asc) }
end
