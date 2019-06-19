class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words do |t|
      t.string :chinese
      t.string :japanese
      t.string :pinyin

      t.timestamps
    end
  end
end
