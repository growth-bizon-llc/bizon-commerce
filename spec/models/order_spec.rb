require 'rails_helper'

RSpec.describe Order, type: :model do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe 'validations' do
    subject { build(:order, store: store) }

    it { should validate_presence_of(:email) }

    it 'validates uniqueness of order_number' do
      create(:order, store: store, order_number: '#1001')
      order = build(:order, store: store, order_number: '#1001')
      expect(order).not_to be_valid
      expect(order.errors[:order_number]).to include('has already been taken')
    end

    it 'auto-generates order_number if blank' do
      order = build(:order, store: store, order_number: nil)
      order.valid?
      expect(order.order_number).to be_present
    end
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:customer).optional }
    it { should have_many(:order_items).dependent(:destroy) }
  end

  describe 'money' do
    it 'monetizes subtotal_cents' do
      order = build(:order, subtotal_cents: 5000)
      expect(order.subtotal).to eq(Money.new(5000, 'USD'))
    end

    it 'monetizes tax_cents' do
      order = build(:order, tax_cents: 400)
      expect(order.tax).to eq(Money.new(400, 'USD'))
    end

    it 'monetizes total_cents' do
      order = build(:order, total_cents: 5400)
      expect(order.total).to eq(Money.new(5400, 'USD'))
    end
  end

  describe 'order_number generation' do
    it 'auto-generates order_number on create' do
      order = Order.create!(store: store, email: 'test@test.com')
      expect(order.order_number).to match(/^#BZ-[A-Z0-9]{8}$/)
    end

    it 'generates unique order numbers' do
      order1 = Order.create!(store: store, email: 'test@test.com')
      order2 = Order.create!(store: store, email: 'test@test.com')
      expect(order1.order_number).not_to eq(order2.order_number)
    end
  end

  describe 'AASM state machine' do
    it 'starts in pending state' do
      order = create(:order, store: store)
      expect(order.status).to eq('pending')
    end

    it 'transitions pending -> confirmed' do
      order = create(:order, store: store)
      order.confirm!
      expect(order.status).to eq('confirmed')
    end

    it 'transitions confirmed -> paid' do
      order = create(:order, :confirmed, store: store)
      order.pay!
      expect(order.status).to eq('paid')
      expect(order.paid_at).to be_present
    end

    it 'transitions paid -> processing' do
      order = create(:order, :paid, store: store)
      order.process_order!
      expect(order.status).to eq('processing')
    end

    it 'transitions processing -> shipped' do
      order = create(:order, :processing, store: store)
      order.ship!
      expect(order.status).to eq('shipped')
      expect(order.shipped_at).to be_present
    end

    it 'transitions shipped -> delivered' do
      order = create(:order, :shipped, store: store)
      order.deliver!
      expect(order.status).to eq('delivered')
      expect(order.delivered_at).to be_present
    end

    it 'transitions pending -> cancelled' do
      order = create(:order, store: store)
      order.cancel!
      expect(order.status).to eq('cancelled')
      expect(order.cancelled_at).to be_present
    end

    it 'transitions confirmed -> cancelled' do
      order = create(:order, :confirmed, store: store)
      order.cancel!
      expect(order.status).to eq('cancelled')
    end

    it 'transitions paid -> refunded' do
      order = create(:order, :paid, store: store)
      order.refund!
      expect(order.status).to eq('refunded')
    end

    it 'cannot transition from pending to paid directly' do
      order = create(:order, store: store)
      expect { order.pay! }.to raise_error(AASM::InvalidTransition)
    end

    it 'cannot cancel a shipped order' do
      order = create(:order, :shipped, store: store)
      expect { order.cancel! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe 'scopes' do
    let!(:pending_order) { create(:order, store: store) }
    let!(:paid_order) { create(:order, :paid, store: store) }

    it '.by_status filters by status' do
      expect(Order.by_status('pending')).to include(pending_order)
      expect(Order.by_status('pending')).not_to include(paid_order)
    end
  end
end
