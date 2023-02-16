require "rails_helper"

RSpec.describe Dispenser, type: :model do
  describe 'Validations' do
    context 'Dispenser without flow_volume' do
      let(:dispenser) { build(:dispenser, flow_volume: nil) }

      it 'Is invalid' do
        expect(dispenser.valid?).to be_falsey
        expect(dispenser.errors.attribute_names).to eq([:flow_volume])
      end
    end

    context 'Dispenser with all data' do
      let(:dispenser) { build(:dispenser) }

      it 'Is valid' do
        expect(dispenser.valid?).to be_truthy
      end
    end
  end

  describe 'Methods' do
    context '#usages' do
      let(:dispenser) { create(:dispenser) }
      let!(:dispenser_usage1) { create(:dispenser_usage, dispenser: dispenser) }
      let!(:dispenser_usage2) { create(:dispenser_usage, dispenser: dispenser) }

      it 'Return the number of usages' do
        expect(dispenser.usages).to eq(2)
      end
    end
  end
end
