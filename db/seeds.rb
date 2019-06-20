# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# 間違っていたので変更した。変更後確認はしていない
5.times do |no|
  User.create()
  Word.create(japanese: no.to_s, chinese: no.to_s, pinyin: no.to_s, level:3)
  Sentence.create(word_id: no+1, japanese: no.to_s, chinese: no.to_s, pinyin: no.to_s)
  RememberedWord.create(user_id: no+1, word_id: no+1)
end