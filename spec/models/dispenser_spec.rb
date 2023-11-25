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
end
