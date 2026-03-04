require 'rails_helper'

RSpec.describe StorePolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:staff_user) { create(:user, :staff, store: store) }

  before { Current.store = store }

  describe '#show?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, store).show?).to be true
    end
  end

  describe '#update?' do
    it 'allows owner' do
      expect(described_class.new(owner, store).update?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, store).update?).to be false
    end

    it 'denies admin' do
      admin_user = create(:user, :admin, store: store)
      expect(described_class.new(admin_user, store).update?).to be false
    end
  end

  describe 'Scope' do
    it 'resolves all stores' do
      scope = double('scope')
      expect(scope).to receive(:all).and_return([store])
      result = described_class::Scope.new(owner, scope).resolve
      expect(result).to include(store)
    end
  end
end
