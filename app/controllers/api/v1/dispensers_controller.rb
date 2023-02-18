# frozen_string_literal: true

class Api::V1::DispensersController < ApplicationController
  def create
    dispenser = Dispenser.create!(dispenser_params)
    render status: '200', json: { id: dispenser.id, flow_volume: dispenser.flow_volume }
  rescue StandardError => _e
    render status: '500', plain: 'Unexpected API error'
  end

  def status
  end

  def spending
  end

  private

  def dispenser_params
    params.permit(:flow_volume)
  end

  def dispenser_status_params
    params.permit(:status, :updated_at)
  end
end
