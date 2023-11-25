# frozen_string_literal: true

class Dispenser < ApplicationRecord
  has_many :dispenser_usages, dependent: :destroy

  validates :flow_volume, presence: true, numericality: true
  validates :price, presence: true, numericality: true

  enum :status, { close: 0, open: 1 }
end
