require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'associations' do
    it { should belong_to(:store) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(staff: 0, admin: 1, owner: 2) }
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe 'roles' do
    it 'defaults to staff' do
      user = User.new
      expect(user.role).to eq('staff')
    end

    it 'can be set to admin' do
      user = build(:user, :admin)
      expect(user.admin?).to be true
    end

    it 'can be set to owner' do
      user = build(:user, :owner)
      expect(user.owner?).to be true
    end
  end

  describe 'devise modules' do
    it 'is database authenticatable' do
      store = create(:store)
      user = create(:user, store: store, password: 'password123')
      expect(user.valid_password?('password123')).to be true
    end
  end
end
