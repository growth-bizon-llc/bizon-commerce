require 'rails_helper'

RSpec.describe BaseService do
  it 'raises NotImplementedError on call' do
    expect { described_class.new.call }.to raise_error(NotImplementedError)
  end

  it 'starts with empty errors' do
    service = described_class.new
    expect(service.errors).to eq([])
    expect(service).to be_success
  end

  it 'is not successful when errors exist' do
    service = described_class.new
    service.errors << "Something went wrong"
    expect(service).not_to be_success
  end
end
