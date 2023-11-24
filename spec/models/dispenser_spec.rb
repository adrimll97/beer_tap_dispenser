# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dispenser, type: :model do
  describe 'Validations' do
    describe 'Check factory validity' do
      let(:dispenser) { build(:dispenser) }

      it 'is valid with valid attributes' do
        expect(dispenser).to be_valid
      end
    end

    describe '#flow_volume' do
      it { is_expected.to validate_presence_of(:flow_volume) }
      it { is_expected.to validate_numericality_of(:flow_volume) }
    end

    describe '#price' do
      it { is_expected.to validate_presence_of(:price) }
      it { is_expected.to validate_numericality_of(:price) }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:dispenser_usages) }
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
