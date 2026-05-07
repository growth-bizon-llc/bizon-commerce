class Category < ApplicationRecord
  include Multi::Scoped
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :store

  has_one_attached :image

  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: :parent_id, dependent: :nullify
  has_many :products, dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, uniqueness: { scope: :store_id }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validate :parent_is_not_self
  validate :acceptable_image

  default_scope -> { kept }
  scope :root, -> { where(parent_id: nil) }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }

  private

  def parent_is_not_self
    errors.add(:parent_id, "can't be self") if parent_id.present? && parent_id == id
  end

  def acceptable_image
    return unless image.attached?

    acceptable_types = ['image/png', 'image/jpeg', 'image/webp', 'image/gif']
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, 'must be a PNG, JPEG, WebP, or GIF')
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, 'is too large (max 5MB)')
    end
  end
end
