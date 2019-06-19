class Word < ApplicationRecord
    validates :chinese, presence: true
    validates :japanese, presence: true
    validates :pinyin, presence: true
end
