class Customer < ApplicationRecord
  include Multi::Scoped

  has_secure_password

  has_many :orders, dependent: :restrict_with_error
  has_many :carts, dependent: :destroy

  validates :email, presence: true, uniqueness: { scope: :store_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
