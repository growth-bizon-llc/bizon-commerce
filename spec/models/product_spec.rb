require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    subject { build(:product, store: store) }

    it { should validate_presence_of(:name) }
    it 'validates uniqueness of slug scoped to store' do
      existing = create(:product, store: store)
      product = build(:product, store: store, name: 'Other')
      # Bypass FriendlyId slug generation to test the DB-level uniqueness validation
      product.define_singleton_method(:should_generate_new_friendly_id?) { false }
      product.slug = existing.slug
      expect(product).not_to be_valid
      expect(product.errors[:slug]).to include('has already been taken')
    end
    it { should validate_numericality_of(:base_price_cents).is_greater_than_or_equal_to(0) }
    it { should validate_inclusion_of(:status).in_array(%w[draft active archived]) }
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:category).optional }
    it { should have_many(:variants).class_name('ProductVariant').dependent(:destroy) }
    it { should have_many(:product_images).dependent(:destroy) }
  end

  describe 'money' do
    it 'monetizes base_price_cents' do
      product = build(:product, base_price_cents: 2500)
      expect(product.base_price).to eq(Money.new(2500, 'USD'))
    end

    it 'monetizes compare_at_price_cents with allow_nil' do
      product = build(:product, compare_at_price_cents: nil)
      expect(product.compare_at_price).to be_nil
    end
  end

  describe 'scopes' do
    let!(:active_prod) { create(:product, :active, store: store) }
    let!(:draft_prod) { create(:product, store: store, status: 'draft') }
    let!(:archived_prod) { create(:product, :archived, store: store) }
    let!(:featured_prod) { create(:product, :active, :featured, store: store) }
    let!(:oos_prod) { create(:product, :active, :out_of_stock, store: store, track_inventory: true) }

    it '.active returns active products' do
      expect(Product.active).to include(active_prod, featured_prod, oos_prod)
      expect(Product.active).not_to include(draft_prod, archived_prod)
    end

    it '.draft returns draft products' do
      expect(Product.draft).to include(draft_prod)
      expect(Product.draft).not_to include(active_prod)
    end

    it '.archived returns archived products' do
      expect(Product.archived).to include(archived_prod)
    end

    it '.featured returns featured products' do
      expect(Product.featured).to include(featured_prod)
      expect(Product.featured).not_to include(active_prod)
    end

    it '.in_stock returns products with stock or not tracking inventory' do
      expect(Product.in_stock).to include(active_prod)
      expect(Product.in_stock).not_to include(oos_prod)
    end
  end

  describe 'soft delete' do
    it 'can be discarded' do
      product = create(:product, store: store)
      product.discard
      expect(product.discarded?).to be true
    end
  end
end
