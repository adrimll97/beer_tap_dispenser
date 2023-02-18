# frozen_string_literal: true

class Dispenser < ApplicationRecord
  has_many :dispenser_usages, dependent: :destroy

  validates :flow_volume, presence: true, numericality: true

  def usages
    dispenser_usages.count
  end
end
