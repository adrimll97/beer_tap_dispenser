class AddFlowVolumeAndPriceToDispenserUsage < ActiveRecord::Migration[6.1]
  def change
    add_column :dispenser_usages, :flow_volume, :float, null: false
    add_column :dispenser_usages, :price, :float, null: false
  end
end
