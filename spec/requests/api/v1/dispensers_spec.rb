# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Dispensers', type: :request do
  shared_examples 'have http status' do |http_status, make_action|
    before do
      send(make_action)
    end

    it { expect(response).to have_http_status(http_status) }
  end

  shared_examples 'Invalid dispenser' do |make_action|
    context 'with invalid dispenser' do
      let(:dispenser_id) { Faker::Number.number(digits: 2) }

      include_examples 'have http status', 404, make_action
    end
  end

  describe 'POST /create' do
    subject(:make_post) { post '/api/v1/dispensers', params: { dispenser: { flow_volume: } } }

    context 'without flow_volume' do
      let(:flow_volume) { nil }

      include_examples 'have http status', 500, 'make_post'
    end

    context 'with invalid flow_volume' do
      let(:flow_volume) { Faker::Lorem.word }

      include_examples 'have http status', 500, 'make_post'
    end

    context 'with valid flow_volume' do
      let(:flow_volume) { Faker::Number.between(from: 0.00, to: 0.10) }

      it 'create new dispenser' do
        aggregate_failures do
          expect { make_post }.to change { Dispenser.count }.to(1)
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe 'PUT /status' do
    subject(:make_put) { put("/api/v1/dispensers/#{dispenser_id}/status", params:) }

    let(:dispenser) { create(:dispenser) }
    let(:dispenser_id) { dispenser.id }

    context 'with invalid dispenser' do
      let(:params) { {} }

      include_examples 'Invalid dispenser', 'make_put'
    end

    context 'without params' do
      let(:params) { {} }

      include_examples 'have http status', 422, 'make_put'
    end

    context 'with invalid params' do
      context 'with status no open or close' do
        let(:params) { { dispenser: { status: 'foo', updated_at: '2023-01-01T02:00:00Z' } } }

        include_examples 'have http status', 422, 'make_put'
      end
    end

    context 'with valid params' do
      let(:change_status_service) { double(ChangeDispenserStatus) }
      let(:status) { Dispenser.statuses.keys.sample }
      let(:updated_at) { '2023-01-01T02:00:00Z' }
      let(:params) { { dispenser: { status:, updated_at: } } }

      before do
        allow(ChangeDispenserStatus).to receive(:new).with(dispenser, status, updated_at)
                                                     .and_return(change_status_service)
      end

      context 'calling service return false' do
        before do
          allow(change_status_service).to receive(:change_status).and_return(false)
        end

        include_examples 'have http status', 409, 'make_put'
      end

      context 'calling service return true' do
        before do
          allow(change_status_service).to receive(:change_status).and_return(true)
        end

        include_examples 'have http status', 202, 'make_put'
      end

      context 'calling service raise an error' do
        before do
          allow(change_status_service).to receive(:change_status).and_raise('foo')
        end

        include_examples 'have http status', 500, 'make_put'
      end
    end
  end

  describe 'GET /spending' do
    subject(:make_get) { get "/api/v1/dispensers/#{dispenser_id}/spending" }

    let(:dispenser) { create(:dispenser) }

    context 'with invalid dispenser' do
      include_examples 'Invalid dispenser', 'make_get'
    end

    context 'with valid dispenser' do
      let(:calcualte_spend_service) { double(CalculateDispenserSpend) }
      let(:dispenser_id) { dispenser.id }

      before do
        allow(CalculateDispenserSpend).to receive(:new).with(dispenser).and_return(calcualte_spend_service)
      end

      context 'calling calculation service return spend hash' do
        before do
          allow(calcualte_spend_service).to receive(:total_spend).and_return(Faker::Json.shallow_json)
        end

        include_examples 'have http status', 200, 'make_get'
      end

      context 'calling calculation service raise an error' do
        before do
          allow(calcualte_spend_service).to receive(:total_spend).and_raise('foo')
        end

        include_examples 'have http status', 500, 'make_get'
      end
    end
  end
end
