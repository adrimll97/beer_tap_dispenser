# frozen_string_literal: true

FactoryBot.define do
  factory :dispenser_usage do
    dispenser { create(:dispenser) }
    opened_at { Time.now - 1.minute }
    closed_at { Time.now }
    total_spend { Faker::Number.number(digits: 2) }
    flow_volume { Faker::Number.between(from: 0.00, to: 0.10) }
    price { Faker::Number.between(from: 0.00, to: 20.00) }
  end
end
