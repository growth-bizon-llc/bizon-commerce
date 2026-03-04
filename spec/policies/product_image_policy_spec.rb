require 'rails_helper'

RSpec.describe ProductImagePolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:staff_user) { create(:user, :staff, store: store) }
  let(:image) { create(:product_image, product: create(:product, store: store), store: store) }

  before { Current.store = store }

  describe '#create?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, image).create?).to be true
    end
  end

  describe '#update?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, image).update?).to be true
    end
  end

  describe '#destroy?' do
    it 'allows owner' do
      expect(described_class.new(owner, image).destroy?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, image).destroy?).to be false
    end
  end
end
