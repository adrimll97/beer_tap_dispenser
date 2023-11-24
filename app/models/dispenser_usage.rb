# frozen_string_literal: true

class DispenserUsage < ApplicationRecord
  VALUE = 12.25

  belongs_to :dispenser

  validates :opened_at, presence: true
  validates :flow_volume, presence: true, numericality: true
  validates :price, presence: true, numericality: true
  validate :opened_at_cannot_be_future
  validate :closed_at_must_be_after_opened_at

  after_update_commit :calculate_total_spend

  def calculate_usage_spend
    end_time = closed_at || Time.now
    time_opened = end_time - opened_at
    time_opened * dispenser.flow_volume * VALUE
  end

  private

  def opened_at_cannot_be_future
    return if opened_at.present? && opened_at <= Time.now

    errors.add(:opened_at, 'cannot be in the future')
  end

  def closed_at_must_be_after_opened_at
    return if closed_at.nil? || closed_at > opened_at

    errors.add(:closed_at, 'cannot be before the open time')
  end

  def calculate_total_spend
    update_columns(total_spend: calculate_usage_spend)
  end
end
