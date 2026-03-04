require 'rails_helper'

RSpec.describe ApplicationPolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:admin_user) { create(:user, :admin, store: store) }
  let(:staff_user) { create(:user, :staff, store: store) }
  let(:record) { double('record') }

  before { Current.store = store }

  describe '#index?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, record).index?).to be true
    end
  end

  describe '#show?' do
    it 'allows all users' do
      expect(described_class.new(staff_user, record).show?).to be true
    end
  end

  describe '#create?' do
    it 'allows admin' do
      expect(described_class.new(admin_user, record).create?).to be true
    end

    it 'allows owner' do
      expect(described_class.new(owner, record).create?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, record).create?).to be false
    end
  end

  describe '#update?' do
    it 'allows admin' do
      expect(described_class.new(admin_user, record).update?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, record).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'allows owner' do
      expect(described_class.new(owner, record).destroy?).to be true
    end

    it 'denies staff' do
      expect(described_class.new(staff_user, record).destroy?).to be false
    end
  end

  describe 'Scope' do
    it 'resolves all records' do
      scope = double('scope')
      expect(scope).to receive(:all).and_return([])
      described_class::Scope.new(owner, scope).resolve
    end
  end
end
