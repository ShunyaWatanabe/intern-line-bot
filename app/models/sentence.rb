class Sentence < ApplicationRecord
  belongs_to :word
  validates :word_id, presence: true
  validates :chinese, presence: true
  validates :japanese, presence: true
  validates :pinyin, presence: true
end
