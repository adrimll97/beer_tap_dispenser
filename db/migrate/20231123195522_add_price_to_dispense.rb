class AddPriceToDispense < ActiveRecord::Migration[6.1]
  def change
    add_column :dispensers, :price, :float, null: false, default: 12.25
  end
end
