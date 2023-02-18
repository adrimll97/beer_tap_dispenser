require 'rails_helper'

RSpec.describe 'Api::V1::Dispensers', type: :request do
  describe 'POST /create' do
    let(:valid_flow) { Faker::Number.between(from: 0.00, to: 0.10) }
    let(:invalid_flow) { Faker::Lorem.word }

    context 'valid params' do
      it 'returns 200' do
        post '/api/v1/dispensers', params: { flow_volume: valid_flow }
        expect(response).to have_http_status('200')
      end
    end

    context 'invalid params' do
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
    context 'valid params' do
      it 'returns 202' do
      end
    end

    context 'invalid params' do
      it 'returns 409' do
      end

      it 'returns 500' do
      end
    end
  end

  describe 'GET /spending' do
    context 'valid params' do
      it 'returns 200' do
      end
    end

    context 'invalid params' do
      it 'returns 404' do
      end

      it 'returns 500' do
      end
    end
  end
end
