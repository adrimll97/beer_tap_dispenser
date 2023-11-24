# frozen_string_literal: true

module Api
  module V1
    class DispensersController < ApplicationController
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
        render_api_error
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
        render_api_error
      end

      def spending
        render status: '200', json: build_spending_response
      rescue StandardError => _e
        render_api_error
      end

      private

      def set_dispenser
        @dispenser = Dispenser.find(params[:id])
      rescue ActiveRecord::RecordNotFound => _e
        render status: '404', plain: 'Requested dispenser does not exist'
      end

      def dispenser_params
        params.require(:dispenser).permit(:flow_volume)
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
        status_param = dispenser_status_params[:status]
        already_open = current_usage.opened_at.present?

        return false if status_param == 'open' && already_open
        return false if status_param == 'close' && !already_open

        true
      end

      def build_spending_response
        amount = 0.0
        usages = []
        dispenser.dispenser_usages.find_each do |usage|
          usage_spend = usage.total_spend || usage.calculate_usage_spend
          amount += usage_spend
          usages << { opened_at: usage.opened_at, closed_at: usage.closed_at,
                      flow_volume: dispenser.flow_volume, total_spend: usage_spend }
        end
        { amount:, usages: }
      end

      def render_api_error
        render status: '500', plain: 'Unexpected API error'
      end
    end
  end
end
