class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :store

  enum :role, { staff: 0, admin: 1, owner: 2 }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: true

  def jwt_payload
    super.merge('store_id' => store_id)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
