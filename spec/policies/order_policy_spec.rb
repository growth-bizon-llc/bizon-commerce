require 'rails_helper'

RSpec.describe OrderPolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:staff_user) { create(:user, :staff, store: store) }
  let(:order) { create(:order, store: store) }

  before { Current.store = store }

  describe '#update?' do
    it 'allows owner' do
      expect(described_class.new(owner, order).update?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, order).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'denies all' do
      expect(described_class.new(owner, order).destroy?).to be false
    end
  end
end
