class Category < ApplicationRecord
  include Multi::Scoped
  include Discard::Model

  extend FriendlyId
  friendly_id :name, use: [:slugged, :scoped], scope: :store

  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: :parent_id, dependent: :nullify
  has_many :products, dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, uniqueness: { scope: :store_id }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validate :parent_is_not_self

  default_scope -> { kept }
  scope :root, -> { where(parent_id: nil) }
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }

  private

  def parent_is_not_self
    errors.add(:parent_id, "can't be self") if parent_id.present? && parent_id == id
  end
end
