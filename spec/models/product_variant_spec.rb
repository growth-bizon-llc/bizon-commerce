require 'rails_helper'

RSpec.describe ProductVariant, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:product) }
  end

  describe 'money' do
    it 'monetizes price_cents' do
      variant = build(:product_variant, price_cents: 3000)
      expect(variant.price).to eq(Money.new(3000, 'USD'))
    end
  end

  describe 'scopes' do
    let(:product) { create(:product, store: store) }
    let!(:active_variant) { create(:product_variant, product: product, store: store, active: true) }
    let!(:inactive_variant) { create(:product_variant, product: product, store: store, active: false) }

    it '.active returns only active variants' do
      expect(ProductVariant.active).to include(active_variant)
      expect(ProductVariant.active).not_to include(inactive_variant)
    end
  end

  describe 'soft delete' do
    it 'can be discarded' do
      product = create(:product, store: store)
      variant = create(:product_variant, product: product, store: store)
      variant.discard
      expect(variant.discarded?).to be true
    end
  end
end
