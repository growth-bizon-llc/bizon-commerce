require 'rails_helper'

RSpec.describe Orders::UpdateStatusService do
  let(:store) { create(:store) }

  before { Current.store = store }

  describe '#call' do
    it 'transitions order to confirmed' do
      order = create(:order, store: store)
      service = described_class.new(order: order, event: 'confirm')
      service.call

      expect(service).to be_success
      expect(service.result.status).to eq('confirmed')
    end

    it 'transitions confirmed to paid' do
      order = create(:order, :confirmed, store: store)
      service = described_class.new(order: order, event: 'pay')
      service.call

      expect(service).to be_success
      expect(service.result.status).to eq('paid')
    end

    it 'fails with invalid event' do
      order = create(:order, store: store)
      service = described_class.new(order: order, event: 'nonexistent')
      service.call

      expect(service).not_to be_success
      expect(service.errors.first).to include("Invalid status transition")
    end

    it 'fails with invalid transition' do
      order = create(:order, store: store)
      service = described_class.new(order: order, event: 'pay')
      service.call

      expect(service).not_to be_success
      expect(service.errors.first).to include("Cannot transition")
    end

    it 'transitions to cancelled from pending' do
      order = create(:order, store: store)
      service = described_class.new(order: order, event: 'cancel')
      service.call

      expect(service).to be_success
      expect(service.result.status).to eq('cancelled')
    end

    it 'transitions paid to refunded' do
      order = create(:order, :paid, store: store)
      service = described_class.new(order: order, event: 'refund')
      service.call

      expect(service).to be_success
      expect(service.result.status).to eq('refunded')
    end

    it 'handles AASM::InvalidTransition gracefully' do
      order = create(:order, store: store)
      # Stub may_fire_event? to return true so it attempts the transition
      allow(order.aasm).to receive(:may_fire_event?).and_return(true)
      allow(order.aasm).to receive(:fire!).and_raise(AASM::InvalidTransition.new(order, 'ship', :default))

      service = described_class.new(order: order, event: 'ship')
      service.call

      expect(service).not_to be_success
    end
  end
end
