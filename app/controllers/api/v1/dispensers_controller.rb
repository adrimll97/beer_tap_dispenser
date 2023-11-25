# frozen_string_literal: true

module Api
  module V1
    class DispensersController < ApplicationController
      STATUS_CHANGED = 'Status of the tap changed correctly'
      DISPENSER_NOT_FOUND = 'Requested dispenser does not exist'
      SAME_STATUS = 'Dispenser is already opened/closed'
      INVALID_STATUS = 'Request body property status must be equal to one of the allowed values: open, close'
      UNEXPECTED_ERROR = 'Unexpected API error'

      before_action :set_dispenser, only: %i[status spending]
      attr_accessor :dispenser

      def create
        dispenser = Dispenser.create!(dispenser_params)
        render status: '200', json: { id: dispenser.id, flow_volume: dispenser.flow_volume }
      rescue StandardError => _e
        render_api_error
      end

      def status
        render_invalid_status_error and return unless valid_status_params?

        status = dispenser_status_params[:status]
        updated_at = dispenser_status_params[:updated_at]
        change_status = ChangeDispenserStatus.new(dispenser, status, updated_at).change_status
        render status: '409', plain: SAME_STATUS and return unless change_status

        render status: '202', plain: STATUS_CHANGED
      rescue ActionController::ParameterMissing => _e
        render_invalid_status_error
      rescue StandardError => _e
        render_api_error
      end

      def spending
        render status: '200', json: CalculateDispenserSpend.new(dispenser).total_spend
      rescue StandardError => _e
        render_api_error
      end

      private

      def set_dispenser
        @dispenser = Dispenser.find(params[:id])
      rescue ActiveRecord::RecordNotFound => _e
        render status: '404', plain: DISPENSER_NOT_FOUND
      end

      def dispenser_params
        params.require(:dispenser).permit(:flow_volume)
      end

      def dispenser_status_params
        return @dispenser_status_params if @dispenser_status_params.present?

        @dispenser_status_params = params.require(:dispenser).permit(:status, :updated_at).tap do |status_params|
          status_params.require(:status)
        end
      end

      def valid_status_params?
        Dispenser.statuses.keys.include? dispenser_status_params[:status]
      end

      def render_api_error
        render status: '500', plain: UNEXPECTED_ERROR
      end

      def render_invalid_status_error
        render status: '422', plain: INVALID_STATUS
      end
    end
  end
end
