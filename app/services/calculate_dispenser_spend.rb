# frozen_string_literal: true

class CalculateDispenserSpend
  attr_reader :dispenser

  def initialize(dispenser)
    @dispenser = dispenser
  end

  def total_spend
    {
      amount: dispenser.dispenser_usages.sum { |usage| usage_spend(usage) },
      usages: dispenser.dispenser_usages.map { |usage| build_usage_spend_hash(usage, usage_spend(usage)) }
    }
  end

  def usage_spend(dispenser_usage)
    return dispenser_usage.total_spend if dispenser_usage.total_spend.present?

    end_time = dispenser_usage.closed_at || Time.now
    time_opened = end_time - dispenser_usage.opened_at
    flow_volume = dispenser_usage.flow_volume
    price = dispenser_usage.price

    calculate_usage_spend(time_opened, flow_volume, price)
  end

  private

  def calculate_usage_spend(time_opened, flow_volume, price)
    time_opened * flow_volume * price
  end

  def build_usage_spend_hash(dispenser_usage, spend)
    {
      opened_at: dispenser_usage.opened_at.to_datetime.rfc3339,
      closed_at: dispenser_usage.closed_at.to_datetime.rfc3339,
      flow_volume: dispenser_usage.flow_volume,
      total_spend: spend
    }
  end
end
