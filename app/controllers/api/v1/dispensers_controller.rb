# frozen_string_literal: true

class Api::V1::DispensersController < ApplicationController
  VALID_STATUSES = {
    open: 'opened_at',
    close: 'closed_at'
  }.with_indifferent_access.freeze

  before_action :set_dispenser, only: %i[status spending]
  attr_accessor :dispenser

  def create
    dispenser = Dispenser.create!(dispenser_params)
    render status: '200', json: { id: dispenser.id, flow_volume: dispenser.flow_volume }
  rescue StandardError => _e
    render status: '500', plain: 'Unexpected API error'
  end

  def status
    current_usage = dispenser.current_usage
    if valid_status?(current_usage)
      update_time = updated_at_time
      current_usage.update!({ "#{VALID_STATUSES[dispenser_status_params[:status]]}": update_time })
      render status: '202', plain: 'Status of the tap changed correctly'
    else
      render status: '409', plain: 'Dispenser is already opened/closed'
    end
  rescue StandardError => _e
    render status: '500', plain: 'Unexpected API error'
  end

  def spending
  end

  private

  def set_dispenser
    @dispenser = Dispenser.find(params[:id])
  end

  def dispenser_params
    params.permit(:flow_volume)
  end

  def dispenser_status_params
    return @dispenser_status_params if @dispenser_status_params.present?

    @dispenser_status_params = params.permit(:id, :status, :updated_at).tap do |dispenser_status_params|
      dispenser_status_params.require(:status)
    end
    @dispenser_status_params.delete_if do |key, val|
      key == 'status' && VALID_STATUSES.keys.exclude?(val)
    end
  end

  def updated_at_time
    dispenser_status_params[:updated_at].present? ? Time.rfc3339(dispenser_status_params[:updated_at]) : Time.now
  end

  def valid_status?(current_usage)
    if current_usage.opened_at.present?
      return false if dispenser_status_params[:status] == 'open'
    elsif dispenser_status_params[:status] == 'close'
      return false
    end
    true
  end
end
