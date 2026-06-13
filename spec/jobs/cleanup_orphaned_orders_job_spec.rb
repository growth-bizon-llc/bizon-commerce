require 'rails_helper'

RSpec.describe CleanupOrphanedOrdersJob, type: :job do
  let(:store) { create(:store) }

  it 'cancels old pending orders' do
    old_order = create(:order, store: store, status: 'pending', created_at: 49.hours.ago)
    recent_order = create(:order, store: store, status: 'pending', created_at: 1.hour.ago)

    described_class.perform_now

    expect(old_order.reload.status).to eq('cancelled')
    expect(recent_order.reload.status).to eq('pending')
  end

  it 'cancels old confirmed orders' do
    old_confirmed = create(:order, store: store, status: 'confirmed', created_at: 49.hours.ago)

    described_class.perform_now

    expect(old_confirmed.reload.status).to eq('cancelled')
  end

  it 'does not cancel paid orders' do
    paid_order = create(:order, :paid, store: store, created_at: 49.hours.ago)

    described_class.perform_now

    expect(paid_order.reload.status).to eq('paid')
  end

  it 'does not cancel orders with paid payment_status' do
    order_paid_status = create(:order, store: store, status: 'confirmed', payment_status: 'paid', created_at: 49.hours.ago)
    described_class.perform_now
    expect(order_paid_status.reload.status).to eq('confirmed')
  end
end
