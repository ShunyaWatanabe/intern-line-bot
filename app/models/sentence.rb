class Sentence < ApplicationRecord
  belongs_to :word
  validates :word_id, uniqueness: true
  validates :chinese, :japanese, :pinyin, presence: true
end
