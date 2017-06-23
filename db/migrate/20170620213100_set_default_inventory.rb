class SetDefaultInventory < ActiveRecord::Migration[5.0]
  def change
    change_column_default :movies, :inventory, 1
  end
end
