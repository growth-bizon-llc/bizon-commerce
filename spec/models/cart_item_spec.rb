require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
    it { should belong_to(:product_variant).optional }
  end

  describe 'money' do
    it 'monetizes unit_price_cents' do
      item = build(:cart_item, unit_price_cents: 2500)
      expect(item.unit_price).to eq(Money.new(2500, 'USD'))
    end
  end

  describe '#total' do
    it 'returns unit_price_cents * quantity' do
      item = build(:cart_item, unit_price_cents: 2500, quantity: 3)
      expect(item.total).to eq(7500)
    end
  end
end
