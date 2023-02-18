# frozen_string_literal: true

class DispenserUsage < ApplicationRecord
  VALUE = 12.25

  belongs_to :dispenser

  validates :opened_at, presence: true
  validate :closed_at_after_opened_at

  after_update_commit :calculate_total_spend

  def calculate_usage_spend
    end_time = closed_at || Time.now
    time_opened = end_time - opened_at
    time_opened * dispenser.flow_volume * VALUE
  end

  private

  def closed_at_after_opened_at
    return if closed_at.nil? || closed_at > opened_at

    errors.add(:closed_at, 'cannot be before the open time')
  end

  def calculate_total_spend
    update_columns(total_spend: calculate_usage_spend)
  end
end
