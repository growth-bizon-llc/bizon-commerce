class ProductImage < ApplicationRecord
  include Multi::Scoped

  has_one_attached :image

  belongs_to :product

  validates :alt_text, length: { maximum: 255 }, allow_nil: true
  validate :image_attached
  validate :acceptable_image

  scope :ordered, -> { order(position: :asc) }

  def image_url
    return nil unless image.attached?

    url_options = { host: ENV.fetch('APP_HOST', 'localhost') }

    if ENV['APP_PROTOCOL'] == 'https' || ENV.fetch('APP_HOST', 'localhost').include?('.')
      url_options[:protocol] = 'https'
    else
      url_options[:port] = ENV.fetch('APP_PORT', 3000)
    end

    Rails.application.routes.url_helpers.rails_blob_url(image, **url_options)
  end

  private

  def image_attached
    errors.add(:image, 'must be attached') unless image.attached?
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
