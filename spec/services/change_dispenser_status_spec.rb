# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChangeDispenserStatus, type: :service do
  describe '#change_status' do
    subject(:change_status) { described_class.new(dispenser, new_status, updated_at).change_status }

    let(:close_status) { Dispenser.statuses.keys[0] }
    let(:open_status) { Dispenser.statuses.keys[1] }

    before do
      Timecop.freeze(Time.local(2023))
    end

    after do
      Timecop.return
    end

    context 'with invalid status' do
      shared_examples 'return false' do
        it { expect(change_status).to be_falsey }
      end

      context 'with open status and dispenser opened' do
        let(:dispenser) { create(:dispenser, :open) }
        let(:new_status) { open_status }
        let(:updated_at) { nil }

        include_examples 'return false'
      end

      context 'with close status and dispenser closed' do
        let(:dispenser) { create(:dispenser, :close) }
        let(:new_status) { close_status }
        let(:updated_at) { nil }

        include_examples 'return false'
      end
    end

    context 'with valid status' do
      shared_examples 'change dispenser status' do
        it { expect { change_status }.to change { dispenser.status }.to(new_status) }
      end

      context 'with open status' do
        let(:dispenser) { create(:dispenser, :close) }
        let(:new_status) { open_status }
        let(:updated_at) { nil }

        it 'create a new dispenser_usage' do
          expect { change_status }.to change { DispenserUsage.count }.by(1)
        end

        include_examples 'change dispenser status'
      end

      context 'with close status' do
        let(:dispenser) { create(:dispenser, :open) }
        let!(:dispenser_usage) do
          create(:dispenser_usage,
                 {
                   dispenser:,
                   flow_volume: dispenser.flow_volume,
                   price: dispenser.price,
                   closed_at: nil
                 })
        end
        let(:new_status) { close_status }
        let(:updated_at) { '2023-01-01T02:00:00Z' }

        it 'update closed_at of the opened dispenser_usage' do
          expect { change_status }.to change { dispenser_usage.reload.closed_at }.to(Time.rfc3339(updated_at))
        end

        include_examples 'change dispenser status'
      end
    end
  end
end
