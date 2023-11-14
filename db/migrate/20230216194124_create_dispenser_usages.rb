# frozen_string_literal: true

class CreateDispenserUsages < ActiveRecord::Migration[6.1]
  def change
    create_table :dispenser_usages do |t|
      t.references :dispenser, null: false, foreign_key: true
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.float :total_spend

      t.timestamps
    end
  end
end
