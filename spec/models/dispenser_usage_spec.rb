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
      let(:calculate_service) { double(CalculateDispenserSpend) }
      let(:dispenser_usage) { create(:dispenser_usage, total_spend: nil) }
      let(:attributes) { { closed_at: dispenser_usage.opened_at + 1.seconds } }
      let(:spend) { Faker::Number.number }

      before do
        allow(CalculateDispenserSpend).to receive(:new).with(dispenser_usage.dispenser).and_return(calculate_service)
        allow(calculate_service).to receive(:usage_spend).with(dispenser_usage).and_return(spend)
      end

      it 'Update total_spend' do
        expect { dispenser_usage.update(attributes) }.to change { dispenser_usage.total_spend }.to(spend)
      end
    end
  end
end
