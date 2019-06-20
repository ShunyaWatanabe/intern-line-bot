# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

5.times do |no|
  User.create()
  Word.create(japanese: no.to_s, chinese: no.to_s, pinyin: no.to_s, level:3)
  Sentence.create(word_id: no+1, japanese: no.to_s, chinese: no.to_s, pinyin: no.to_s)
  RememberedWord.create(user_id: no+1, word_id: no+1)
end

Word.create(japanese: 'レベル１日本語', chinese: 'レベル１中国語', pinyin: 'レベル１ピンイン', level:1)
Word.create(japanese: 'レベル２日本語', chinese: 'レベル２中国語', pinyin: 'レベル２ピンイン', level:2)

Sentence.create(word_id:6, japanese: 'レベル１例文', chinese: 'レベル１例文', pinyin: 'レベル１例文')
Sentence.create(word_id:7, japanese: 'レベル２例文', chinese: 'レベル２例文', pinyin: 'レベル２例文')