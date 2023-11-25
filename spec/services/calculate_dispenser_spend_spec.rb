# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalculateDispenserSpend, type: :service do
  let(:spend) { 0.79625 }

  describe '#total_spend' do
    subject(:calculate_spend) { described_class.new(dispenser).total_spend }

    before do
      allow_any_instance_of(described_class).to receive(:usage_spend).and_return(spend)
    end

    shared_examples 'return hash with spend data' do
      let(:usages_array) do
        dispenser.dispenser_usages.map do |usage|
          {
            opened_at: usage.opened_at.to_datetime.rfc3339,
            closed_at: usage.closed_at.to_datetime.rfc3339,
            flow_volume: usage.flow_volume,
            total_spend: spend
          }
        end
      end
      let(:total_spend_hash) do
        {
          amount: spend * dispenser.dispenser_usages.count,
          usages: usages_array
        }
      end

      it { is_expected.to eq(total_spend_hash) }
    end

    context 'dispenser without usages' do
      let(:dispenser) { create(:dispenser) }
      let(:total_spend_hash) { { amount: 0, usages: [] } }

      include_examples 'return hash with spend data'
    end

    context 'dispenser with a usage' do
      let(:dispenser_usage) { create(:dispenser_usage) }
      let(:dispenser) { dispenser_usage.dispenser }

      include_examples 'return hash with spend data'
    end

    context 'dispenser with more than a usage' do
      let(:dispenser) { create(:dispenser) }
      let(:dispenser_usages) { create_list(:dispenser_usage, Faker::Number.between(from: 2, to: 10)) }

      include_examples 'return hash with spend data'
    end
  end

  describe '#usage_spend' do
    subject(:calculate_spend) { described_class.new(dispenser).usage_spend(dispenser_usage) }

    context 'dispenser usage with total_spend' do
      let(:dispenser_usage) { create(:dispenser_usage) }
      let(:dispenser) { dispenser_usage.dispenser }

      it 'return total_spend' do
        expect(calculate_spend).to eq(dispenser_usage.total_spend)
      end
    end

    context 'dispenser usage without total_spend' do
      let(:time_now) { Time.local(2023) }
      let(:attributes) do
        {
          opened_at: time_now - 1.second,
          total_spend: nil,
          flow_volume: 0.065,
          price: 12.25
        }
      end

      before do
        Timecop.freeze(time_now)
      end

      after do
        Timecop.return
      end

      shared_examples 'return calculated spend' do
        it { is_expected.to eq(spend) }
      end

      context 'dispenser closed' do
        let(:attributes_closed) { attributes.merge(closed_at: time_now) }
        let(:dispenser_usage) { create(:dispenser_usage, attributes_closed) }
        let(:dispenser) { dispenser_usage.dispenser }

        include_examples 'return calculated spend'
      end

      context 'dispenser not closed' do
        let(:dispenser_usage) { create(:dispenser_usage, attributes) }
        let(:dispenser) { dispenser_usage.dispenser }

        include_examples 'return calculated spend'
      end
    end
  end
end
