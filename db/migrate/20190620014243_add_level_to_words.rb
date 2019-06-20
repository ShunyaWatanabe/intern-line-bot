class AddLevelToWords < ActiveRecord::Migration[5.1]
  def change
    add_column :words, :level, :integer
  end
end
