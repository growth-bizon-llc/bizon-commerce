class ProductImage < ApplicationRecord
  include Multi::Scoped

  has_one_attached :image

  belongs_to :product

  validates :alt_text, length: { maximum: 255 }, allow_nil: true
  validate :image_attached

  scope :ordered, -> { order(position: :asc) }

  def image_url
    return nil unless image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      image,
      host: ENV.fetch('APP_HOST', 'localhost'),
      port: ENV.fetch('APP_PORT', 3000)
    )
  end

  private

  def image_attached
    errors.add(:image, 'must be attached') unless image.attached?
  end
end
