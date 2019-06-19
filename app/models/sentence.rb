class Sentence < ApplicationRecord
  belongs_to :word
  validates :chinese, presence: true
  validates :japanese, presence: true
  validates :pinyin, presence: true
end
