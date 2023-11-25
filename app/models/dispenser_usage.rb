# frozen_string_literal: true

class DispenserUsage < ApplicationRecord
  belongs_to :dispenser

  validates :opened_at, presence: true
  validates :closed_at, comparison: { greater_than: :opened_at }, allow_nil: true
  validates :flow_volume, presence: true, numericality: true
  validates :price, presence: true, numericality: true

  after_update_commit :calculate_total_spend, if: :closed_at_previously_changed?

  private

  def calculate_total_spend
    update_columns(total_spend: CalculateDispenserSpend.new(dispenser).usage_spend(self))
  end
end
