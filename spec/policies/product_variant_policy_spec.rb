require 'rails_helper'

RSpec.describe ProductVariantPolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:staff_user) { create(:user, :staff, store: store) }
  let(:variant) { create(:product_variant, product: create(:product, store: store), store: store) }

  before { Current.store = store }

  describe '#create?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, variant).create?).to be true
    end
  end

  describe '#update?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, variant).update?).to be true
    end
  end

  describe '#destroy?' do
    it 'allows owner' do
      expect(described_class.new(owner, variant).destroy?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, variant).destroy?).to be false
    end
  end
end
