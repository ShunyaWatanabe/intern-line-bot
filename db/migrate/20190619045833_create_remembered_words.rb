class CreateRememberedWords < ActiveRecord::Migration[5.1]
  def change
    create_table :remembered_words do |t|
      t.references :user, foreign_key: true
      t.references :word, foreign_key: true

      t.timestamps
    end
  end
end
