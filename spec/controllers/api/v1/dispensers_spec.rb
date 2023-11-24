# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Dispensers', type: :request do
  describe 'POST /create' do
    let(:valid_flow) { Faker::Number.between(from: 0.00, to: 0.10) }
    let(:invalid_flow) { Faker::Lorem.word }

    context 'success' do
      it 'returns 200' do
        post '/api/v1/dispensers', params: { dispenser: { flow_volume: valid_flow } }
        expect(response).to have_http_status('200')
      end
    end

    context 'fails' do
      it 'returns 500 with invalid flow_volume' do
        post '/api/v1/dispensers', params: { dispenser: { flow_volume: invalid_flow } }
        expect(response).to have_http_status('500')
      end

      it 'returns 500 without flow_volume' do
        post '/api/v1/dispensers'
        expect(response).to have_http_status('500')
      end
    end
  end

  describe 'PUT /status' do
    let(:dispenser) { create(:dispenser) }

    context 'success' do
      it 'returns 202 opening the tap with all params' do
        params = { status: 'open', updated_at: '2022-01-01T02:00:00Z' }
        put("/api/v1/dispensers/#{dispenser.id}/status", params: params)
        expect(response).to have_http_status('202')
      end

      it 'returns 202 closing the tap and without updated_at param' do
        dispenser.dispenser_usages.create(opened_at: Time.now - 1.minute,
                                          flow_volume: dispenser.flow_volume,
                                          price: dispenser.price)
        params = { status: 'close' }
        put("/api/v1/dispensers/#{dispenser.id}/status", params: params)
        expect(response).to have_http_status('202')
      end
    end

    context 'fails' do
      it 'returns 409 opening the tap' do
        dispenser.dispenser_usages.create(opened_at: Time.now - 1.minute,
                                          flow_volume: dispenser.flow_volume,
                                          price: dispenser.price)
        params = { status: 'open' }
        put("/api/v1/dispensers/#{dispenser.id}/status", params: params)
        expect(response).to have_http_status('409')
      end

      it 'returns 409 closing the tap' do
        params = { status: 'close', updated_at: '2022-01-01T02:00:00Z' }
        put("/api/v1/dispensers/#{dispenser.id}/status", params: params)
        expect(response).to have_http_status('409')
      end

      it 'returns 500 without params' do
        put "/api/v1/dispensers/#{dispenser.id}/status", params: {}
        expect(response).to have_http_status('500')
      end

      it 'returns 500 with invalidad status' do
        params = { status: 'invalid' }
        put("/api/v1/dispensers/#{dispenser.id}/status", params: params)
        expect(response).to have_http_status('500')
      end
    end
  end

  describe 'GET /spending' do
    let(:opened_at) { Time.rfc3339('2022-01-01T02:00:00Z') }
    let(:closed_at) { Time.rfc3339('2022-01-01T02:00:50Z') }
    let(:now) { Time.rfc3339('2022-01-01T02:01:00Z') }
    let(:dispenser) { create(:dispenser, flow_volume: 0.065) }
    let!(:dispenser_usage_closed) do
      create(:dispenser_usage, { dispenser:, opened_at:, closed_at:, total_spend: nil })
    end
    let!(:dispenser_usage_not_closed) do
      create(:dispenser_usage, dispenser:, opened_at:, closed_at: nil, total_spend: nil)
    end

    let(:success_response) do
      {
        'amount' => 87.5875,
        'usages' =>
        [
          { 'opened_at' => '2022-01-01T02:00:00.000Z',
            'closed_at' => '2022-01-01T02:00:50.000Z',
            'flow_volume' => 0.065,
            'total_spend' => 39.8125 },
          { 'opened_at' => '2022-01-01T02:00:00.000Z',
            'closed_at' => nil,
            'flow_volume' => 0.065,
            'total_spend' => 47.775000000000006 }
        ]
      }
    end

    context 'success' do
      it 'returns 200' do
        allow(Time).to receive(:now).and_return(now)
        get "/api/v1/dispensers/#{dispenser.id}/spending"
        expect(response).to have_http_status('200')
        expect(JSON.parse(response.body)).to eq(success_response)
      end
    end

    context 'fails' do
      it 'returns 404' do
        get "/api/v1/dispensers/#{Faker::Number.number(digits: 2)}/spending"
        expect(response).to have_http_status('404')
      end

      it 'returns 500' do
        allow_any_instance_of(DispenserUsage).to receive(:calculate_usage_spend).and_raise('Error')
        get "/api/v1/dispensers/#{dispenser.id}/spending"
        expect(response).to have_http_status('500')
      end
    end
  end
end
