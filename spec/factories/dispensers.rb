# frozen_string_literal: true

FactoryBot.define do
  factory :dispenser do
    flow_volume { Faker::Number.between(from: 0.00, to: 0.10) }
  end
end
