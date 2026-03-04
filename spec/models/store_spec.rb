require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'validations' do
    subject { build(:store) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_uniqueness_of(:custom_domain).allow_nil }
    it { should validate_uniqueness_of(:subdomain).allow_nil }
  end

  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:products).dependent(:destroy) }
    it { should have_many(:product_variants).dependent(:restrict_with_error) }
    it { should have_many(:product_images).dependent(:restrict_with_error) }
    it { should have_many(:customers).dependent(:destroy) }
    it { should have_many(:carts).dependent(:destroy) }
    it { should have_many(:orders).dependent(:restrict_with_error) }
  end

  describe 'friendly_id' do
    it 'generates slug from name' do
      store = create(:store, name: 'My Test Store', slug: nil)
      expect(store.slug).to eq('my-test-store')
    end
  end

  describe 'defaults' do
    let(:store) { Store.new(name: 'Test') }

    it 'defaults currency to USD' do
      expect(store.currency).to eq('USD')
    end

    it 'defaults locale to en' do
      expect(store.locale).to eq('en')
    end

    it 'defaults active to true' do
      expect(store.active).to be true
    end

    it 'defaults settings to empty hash' do
      expect(store.settings).to eq({})
    end
  end
end
