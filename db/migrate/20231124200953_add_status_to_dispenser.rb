class AddStatusToDispenser < ActiveRecord::Migration[7.0]
  def change
    add_column :dispensers, :status, :integer, null: false, default: 0
  end
end
