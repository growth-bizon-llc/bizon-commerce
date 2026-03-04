require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    subject { build(:category, store: store) }

    it { should validate_presence_of(:name) }
    it 'validates uniqueness of slug scoped to store' do
      existing = create(:category, store: store)
      category = build(:category, store: store, name: 'Other')
      # Bypass FriendlyId slug generation to test the DB-level uniqueness validation
      category.define_singleton_method(:should_generate_new_friendly_id?) { false }
      category.slug = existing.slug
      expect(category).not_to be_valid
      expect(category.errors[:slug]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:parent).class_name('Category').optional }
    it { should have_many(:children).class_name('Category').with_foreign_key(:parent_id).dependent(:nullify) }
    it { should have_many(:products).dependent(:nullify) }
  end

  describe 'scopes' do
    let!(:active_cat) { create(:category, store: store, active: true) }
    let!(:inactive_cat) { create(:category, store: store, active: false) }
    let!(:parent_cat) { create(:category, store: store) }
    let!(:child_cat) { create(:category, store: store, parent: parent_cat) }

    it '.active returns only active categories' do
      expect(Category.active).to include(active_cat)
      expect(Category.active).not_to include(inactive_cat)
    end

    it '.root returns categories without parent' do
      expect(Category.root).to include(active_cat, inactive_cat, parent_cat)
      expect(Category.root).not_to include(child_cat)
    end
  end

  describe 'soft delete' do
    it 'can be discarded' do
      category = create(:category, store: store)
      category.discard
      expect(category.discarded?).to be true
      expect(Category.kept).not_to include(category)
    end
  end

  describe 'multi-tenant scope' do
    let(:other_store) { create(:store) }
    let!(:cat1) { create(:category, store: store) }

    it 'scopes to current store' do
      Current.store = other_store
      create(:category, store: other_store)
      expect(Category.count).to eq(1)

      Current.store = store
      expect(Category.count).to eq(1)
      expect(Category.first).to eq(cat1)
    end
  end
end
