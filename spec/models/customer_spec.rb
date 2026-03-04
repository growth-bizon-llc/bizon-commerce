require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    subject { build(:customer, store: store) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).scoped_to(:store_id) }
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should have_many(:orders) }
    it { should have_many(:carts).dependent(:destroy) }
  end

  describe 'has_secure_password' do
    it 'authenticates with correct password' do
      customer = create(:customer, store: store, password: 'password123')
      expect(customer.authenticate('password123')).to eq(customer)
    end

    it 'does not authenticate with wrong password' do
      customer = create(:customer, store: store, password: 'password123')
      expect(customer.authenticate('wrong')).to be false
    end
  end
end
