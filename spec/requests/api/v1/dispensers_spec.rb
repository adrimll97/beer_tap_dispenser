require 'rails_helper'

RSpec.describe 'Api::V1::Dispensers', type: :request do
  describe 'POST /create' do
    let(:valid_flow) { Faker::Number.between(from: 0.00, to: 0.10) }
    let(:invalid_flow) { Faker::Lorem.word }

    context 'success' do
      it 'returns 200' do
        post '/api/v1/dispensers', params: { flow_volume: valid_flow }
        expect(response).to have_http_status('200')
      end
    end

    context 'fails' do
      it 'returns 500 with invalid flow_volume' do
        post '/api/v1/dispensers', params: { flow_volume: invalid_flow }
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
        put "/api/v1/dispensers/#{dispenser.id}/status", params: params
        expect(response).to have_http_status('202')
      end

      it 'returns 202 closing the tap and without updated_at param' do
        dispenser.dispenser_usages.create(opened_at: Time.now - 1.minute)
        params = { status: 'close' }
        put "/api/v1/dispensers/#{dispenser.id}/status", params: params
        expect(response).to have_http_status('202')
      end
    end

    context 'fails' do
      it 'returns 409 opening the tap' do
        dispenser.dispenser_usages.create(opened_at: Time.now - 1.minute)
        params = { status: 'open' }
        put "/api/v1/dispensers/#{dispenser.id}/status", params: params
        expect(response).to have_http_status('409')
      end

      it 'returns 409 closing the tap' do
        params = { status: 'close', updated_at: '2022-01-01T02:00:00Z' }
        put "/api/v1/dispensers/#{dispenser.id}/status", params: params
        expect(response).to have_http_status('409')
      end

      it 'returns 500 without params' do
        put "/api/v1/dispensers/#{dispenser.id}/status", params: {}
        expect(response).to have_http_status('500')
      end

      it 'returns 500 with invalidad status' do
        params = { status: 'invalid' }
        put "/api/v1/dispensers/#{dispenser.id}/status", params: params
        expect(response).to have_http_status('500')
      end
    end
  end

  describe 'GET /spending' do
    context 'success' do
      it 'returns 200' do
      end
    end

    context 'fails' do
      it 'returns 404' do
      end

      it 'returns 500' do
      end
    end
  end
end
