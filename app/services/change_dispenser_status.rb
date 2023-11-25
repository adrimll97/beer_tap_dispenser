# frozen_string_literal: true

class ChangeDispenserStatus
  CLOSE = Dispenser.statuses.keys[0]
  OPEN = Dispenser.statuses.keys[1]
  COLUMNS_TO_UPDATE = {
    "#{CLOSE}": 'closed_at',
    "#{OPEN}": 'opened_at'
  }.with_indifferent_access.freeze

  attr_reader :dispenser, :new_status, :column_to_update, :updated_at

  def initialize(dispenser, new_status, updated_at = nil)
    @dispenser = dispenser
    @new_status = new_status
    @column_to_update = COLUMNS_TO_UPDATE[new_status]
    @updated_at = updated_at_time(updated_at)
  end

  def change_status
    return false unless valid_status?

    dispenser_usage.update!({ column_to_update.to_sym => updated_at })
    dispenser.update!(status: new_status)
  end

  private

  def updated_at_time(updated_at)
    updated_at ? Time.rfc3339(updated_at) : Time.now
  end

  def valid_status?
    return false if new_status == OPEN && dispenser.open?
    return false if new_status == CLOSE && dispenser.close?

    true
  end

  def dispenser_usage
    case new_status
    when OPEN
      new_dispenser_usage
    when CLOSE
      dispenser.dispenser_usages.find_by(closed_at: nil)
    end
  end

  def new_dispenser_usage
    flow_volume = dispenser.flow_volume
    price = dispenser.price
    dispenser.dispenser_usages.new(flow_volume:, price:)
  end
end
