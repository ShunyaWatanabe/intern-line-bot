namespace :scraping do
  require 'open-uri'
  desc 'ウェブサイトから中国語のデータを取ってきてデータベースに入れる'
  task :chinese => :environment do
    CHINESE_WORDS_ROOT_URI = 'http://chugokugo-script.net/tango'
    word_classes = ['doushi','meishi','keiyoushi']
    for level in 1..3 do
      for index in 0..2 do 
        charset = nil
        html = open("#{CHINESE_WORDS_ROOT_URI}/level#{level.to_s}/#{word_classes[index]}.html") do |f|
          charset = f.charset
          f.read
        end
        
        # 文字化け対応
        if charset == "iso-8859-1"
          charset = html.scan(/charset="?([^\s"]*)/i).first.join
        end

        doc = Nokogiri::HTML.parse(html, nil, charset)
        lines = doc.xpath('//section/div[@class="divBunruiBox"]')

        lines.each do |line|
          word = Word.create_with(pinyin: line.css('.divBunruiP').inner_text, japanese: line.css('.divBunruiN').inner_text, level: level).find_or_create_by(chinese: line.css('.divBunruiC').inner_text)
          Sentence.create_with(chinese: line.css('.divBunruiExC').inner_text, pinyin: line.css('.divBunruiExP').inner_text, japanese: line.css('.divBunruiExN').inner_text).find_or_create_by(word: word)
        end
      end
    end
  end
end
