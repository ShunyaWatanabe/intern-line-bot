class CreateWords < ActiveRecord::Migration[5.1]
  def change
    create_table :words do |t|
      t.string :chinese, null: false
      t.string :japanese, null: false
      t.string :pinyin, null: false

      t.timestamps
    end
  end
end
