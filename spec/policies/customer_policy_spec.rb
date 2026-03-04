require 'rails_helper'

RSpec.describe CustomerPolicy do
  let(:store) { create(:store) }
  let(:owner) { create(:user, :owner, store: store) }
  let(:customer) { create(:customer, store: store) }

  before { Current.store = store }

  describe '#create?' do
    it 'denies all' do
      expect(described_class.new(owner, customer).create?).to be false
    end
  end

  describe '#update?' do
    it 'denies all' do
      expect(described_class.new(owner, customer).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'denies all' do
      expect(described_class.new(owner, customer).destroy?).to be false
    end
  end
end
