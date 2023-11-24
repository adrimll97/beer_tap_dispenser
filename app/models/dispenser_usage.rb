# frozen_string_literal: true

class DispenserUsage < ApplicationRecord
  VALUE = 12.25

  belongs_to :dispenser

  validates :opened_at, presence: true
  validates :opened_at, comparison: { less_than_or_equal_to: Time.now }
  validates :closed_at, comparison: { greater_than: :opened_at }, allow_nil: true
  validates :flow_volume, presence: true, numericality: true
  validates :price, presence: true, numericality: true

  after_update_commit :calculate_total_spend

  def calculate_usage_spend
    end_time = closed_at || Time.now
    time_opened = end_time - opened_at
    time_opened * dispenser.flow_volume * VALUE
  end

  private

  def calculate_total_spend
    update_columns(total_spend: calculate_usage_spend)
  end
end
