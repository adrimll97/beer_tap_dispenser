# frozen_string_literal: true

class CreateDispensers < ActiveRecord::Migration[6.1]
  def change
    create_table :dispensers do |t|
      t.float :flow_volume, null: false

      t.timestamps
    end
  end
end
