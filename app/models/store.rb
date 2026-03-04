class Store < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :users, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :product_variants, dependent: :restrict_with_error
  has_many :product_images, dependent: :restrict_with_error
  has_many :customers, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, uniqueness: true
  validates :currency, length: { is: 3 }, allow_nil: true
  validates :custom_domain, uniqueness: true, allow_nil: true
  validates :subdomain, uniqueness: true, allow_nil: true
end
