require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:product_name) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
    it { should belong_to(:product_variant).optional }
  end

  describe 'money' do
    it 'monetizes unit_price_cents' do
      item = build(:order_item, unit_price_cents: 2500)
      expect(item.unit_price).to eq(Money.new(2500, 'USD'))
    end

    it 'monetizes total_cents' do
      item = build(:order_item, total_cents: 5000)
      expect(item.total).to eq(Money.new(5000, 'USD'))
    end
  end
end
