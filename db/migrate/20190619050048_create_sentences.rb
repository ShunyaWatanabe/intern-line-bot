class CreateSentences < ActiveRecord::Migration[5.1]
  def change
    create_table :sentences do |t|
      t.references :word, foreign_key: true
      t.string :chinese, null: false
      t.string :japanese, null: false
      t.string :pinyin, null: false

      t.timestamps
    end
  end
end
