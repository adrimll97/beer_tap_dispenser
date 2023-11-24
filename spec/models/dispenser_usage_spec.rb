# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DispenserUsage, type: :model do
  describe 'Validations' do
    describe 'Check factory validity' do
      let(:dispenser_usage) { build(:dispenser_usage) }

      it 'is valid with valid attributes' do
        expect(dispenser_usage).to be_valid
      end
    end

    describe '#opened_at' do
      it { is_expected.to validate_presence_of(:opened_at) }
    end

    describe '#flow_volume' do
      it { is_expected.to validate_presence_of(:flow_volume) }
      it { is_expected.to validate_numericality_of(:flow_volume) }
    end

    describe '#price' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to validate_numericality_of(:price) }
    end

    describe '#opened_at' do
      it { is_expected.to validate_presence_of(:opened_at) }

      context 'cannot be in the future' do
        let(:dispenser_usage) { build(:dispenser_usage, opened_at: Time.now + 1.hour, closed_at: nil) }

        before do
          dispenser_usage.valid?
        end

        it 'is invalid with opened_at in the future' do
          expect(dispenser_usage.errors[:opened_at].size).to eq(1)
        end
      end
    end

    describe '#closed_at' do
      context 'must be after opened_at' do
        let(:dispenser_usage) { build(:dispenser_usage, opened_at: Time.now, closed_at: Time.now - 1.minute) }

        before do
          dispenser_usage.valid?
        end

        it 'is invalid with closed_at after opened_at' do
          expect(dispenser_usage.errors[:closed_at].size).to eq(1)
        end
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:dispenser) }
  end

  describe 'Callbacks' do
    context '#calculate_total_spend' do
      let!(:dispenser_usage) { create(:dispenser_usage, closed_at: nil, total_spend: nil) }

      it 'Update total_spend' do
        dispenser_usage.closed_at = Time.now
        dispenser_usage.save
        expect(dispenser_usage).not_to be_nil
      end
    end
  end

  describe 'Methods' do
    context '#calculate_usage_spend' do
      let(:opened_at) { Time.rfc3339('2022-01-01T02:00:00Z') }
      let(:closed_at) { Time.rfc3339('2022-01-01T02:00:50Z') }
      let(:now) { Time.rfc3339('2022-01-01T02:01:00Z') }
      let(:dispenser) { create(:dispenser, flow_volume: 0.065) }
      let!(:dispenser_usage_closed) do
        create(:dispenser_usage, dispenser:, opened_at:, closed_at:)
      end
      let!(:dispenser_usage_not_closed) do
        create(:dispenser_usage, dispenser:, opened_at:, closed_at: nil)
      end

      it 'Calculate spend with closed_at time' do
        result = dispenser_usage_closed.calculate_usage_spend
        expect(result).to eq(39.8125)
      end

      it 'Calculate spend without closed_at time' do
        expect(Time).to receive(:now).and_return(now)
        result = dispenser_usage_not_closed.calculate_usage_spend
        expect(result).to eq(47.775000000000006)
      end
    end
  end
end
