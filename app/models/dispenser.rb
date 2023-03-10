# frozen_string_literal: true

class Dispenser < ApplicationRecord
  has_many :dispenser_usages, dependent: :destroy

  validates :flow_volume, presence: true, numericality: true

  def current_usage
    dispenser_usages.find_by(closed_at: nil) || dispenser_usages.new
  end
end
