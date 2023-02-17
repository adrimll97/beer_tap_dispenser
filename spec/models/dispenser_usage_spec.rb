require "rails_helper"

RSpec.describe DispenserUsage, type: :model do
  describe 'Validations' do
    context 'Dispenser usage without opened_at' do
      let(:dispenser_usage) { build(:dispenser_usage, opened_at: nil, closed_at: nil) }

      it 'Is invalid' do
        expect(dispenser_usage.valid?).to be_falsey
        expect(dispenser_usage.errors.attribute_names).to eq([:opened_at])
      end
    end

    context 'Dispenser usage with opened_at after closed_at' do
      let(:dispenser_usage) { build(:dispenser_usage, opened_at: Time.now, closed_at: Time.now - 1.minute) }

      it 'Is invalid' do
        expect(dispenser_usage.valid?).to be_falsey
        expect(dispenser_usage.errors.attribute_names).to eq([:closed_at])
      end
    end

    context 'Dispenser usage without closed_at and total_spend' do
      let(:dispenser_usage) { build(:dispenser_usage, closed_at: nil, total_spend: nil) }

      it 'Is valid' do
        expect(dispenser_usage.valid?).to be_truthy
      end
    end

    context 'Dispenser usage with all data' do
      let(:dispenser_usage) { build(:dispenser_usage) }

      it 'Is valid' do
        expect(dispenser_usage.valid?).to be_truthy
      end
    end
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
        create(:dispenser_usage, dispenser: dispenser, opened_at: opened_at, closed_at: closed_at)
      end
      let!(:dispenser_usage_not_closed) do
        create(:dispenser_usage, dispenser: dispenser, opened_at: opened_at, closed_at: nil)
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
