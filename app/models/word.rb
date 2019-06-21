class Word < ApplicationRecord
  SOURCE = 'ja'
  TARGET = 'zh-cn'
  TRANSLATION_ROOT_URI = ENV["TRANSLATION_ROOT_URI"]
  
  has_one :sentence
  
  validates :chinese, :japanese, :pinyin, :level, presence: true

  def self.get_response_message(text)
    if text.include?('Give me a word')
      random_chinese = get_random_chinese(text)
      format_message(random_chinese)
    else
      translation_uri = URI.encode("#{TRANSLATION_ROOT_URI}?source=#{SOURCE}&target=#{TARGET}&text=#{text}")
      translation = get_json_translation(URI.parse(translation_uri))
      pinyin_uri = URI.encode("https://pinyin-rest.pepebecker.com/pinyin/#{translation['message']}")
      pinyin = get_json_translation(URI.parse(pinyin_uri))
      message = <<~EOS
        中国語：#{translation['message']}
        ピンイン：#{pinyin['text']}
      EOS
      format_message(message.chomp)
    end
  end

  def to_message
    message = <<~EOS
      新しい単語：#{chinese}
      発音：#{pinyin}
      意味：#{japanese}
      レベル：#{level}
      例文：
        #{sentence.chinese}
        #{sentence.pinyin}
        #{sentence.japanese}
    EOS
    message.chomp
  end

  private
  def self.get_random_chinese(text)
    level = 1
    if text.include?('(level 2)') or text.include?('(level 2)')
      level = 2
    elsif text.include?('(level 3)') or text.include?('(level 2)')
      level = 3
    end

    word = random_chinese_from_db(level)
    word.to_message
  end

  def self.random_chinese_from_db(level)
    chinese_word = Word.where(level: level).sample
  end

  def self.format_message(message)
    {
      type: 'text',
      text: message
    }
  end

  def self.get_translation(uri)
    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPRedirection
      get_translation(URI.parse(response["location"]))
    else
      response.body
    end
  end
    
  def self.get_json_translation(uri)
    JSON.parse(get_translation(uri)) # -> レスポンスをjsonで変換して返してくれる
  end
end
