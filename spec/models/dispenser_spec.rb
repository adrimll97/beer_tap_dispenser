# frozen_string_literal: true

require 'rails_helper'

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
    context '#current_usage' do
      let(:dispenser1) { create(:dispenser) }
      let(:dispenser2) { create(:dispenser) }
      let!(:dispenser_usage1) do
        create(:dispenser_usage, dispenser: dispenser1, closed_at: nil)
      end

      it 'Return dispenser_usage opened' do
        expect(dispenser1.current_usage.id).to eq(dispenser_usage1.id)
      end

      it 'Return new dispenser_usage' do
        expect(dispenser2.current_usage.id).to be_nil
      end
    end
  end
end
