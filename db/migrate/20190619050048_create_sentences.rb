class CreateSentences < ActiveRecord::Migration[5.1]
  def change
    create_table :sentences do |t|
      t.references :word, foreign_key: true
      t.string :chinese
      t.string :japanese
      t.string :pinyin

      t.timestamps
    end
  end
end
