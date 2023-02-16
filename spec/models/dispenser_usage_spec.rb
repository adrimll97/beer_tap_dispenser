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
end
