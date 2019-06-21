# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# functions
def format_word(japanese, chinese, pinyin, level, sentence_japanese, sentence_chinese, sentence_pinyin)
  {
    japanese: japanese,
    chinese: chinese,
    pinyin: pinyin,
    level: level,
    sentence: {
      japanese: sentence_japanese,
      chinese: sentence_chinese,
      pinyin: sentence_pinyin
    }
  }
end


# variables/data
word1 = format_word('人','人','rén', 1, '彼はどこの国の人ですか？', '他是哪国人？', 'Tā shì nǎ guó rén?')
word2 = format_word('父・父親', '父亲', 'fùqin', 2, '彼の父親はお医者さんです。', '他的父亲是位医生。', 'Tā de fùqin shì wèi yīshēng.')
word3 = format_word('夫（口語表現）', '老公', 'lǎogōng', 3, 'うちのだんなはシャイな性格で無口です。', '我老公性格内向，不爱说话。', 'Wǒ lǎogōng xìnggé nèixiàng，bú ài shuō　huà．')
word4 = format_word('奥さん・妻（口語表現', '太太', 'tàitai', 3, '奥様は大変な美人だそうで。', '听说您太太很漂亮。', 'Tīngshuō nín tàitai hěn piàoliang．')

sample_words = [word1, word2, word3, word4]


# data injection
sample_words.each do |w|
  word = Word.create_with(chinese: w[:chinese], pinyin: w[:pinyin], level: w[:level]).find_or_create_by(japanese: w[:japanese])
  Sentence.create_with(japanese: w[:sentence][:japanese], chinese: w[:sentence][:chinese], pinyin: w[:sentence][:pinyin]).find_or_create_by(word: word)
end