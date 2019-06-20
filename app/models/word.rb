class Word < ApplicationRecord
  SOURCE = 'ja'
  TARGET = 'zh-cn'
  TRANSLATION_ROOT_URI = ENV["TRANSLATION_ROOT_URI"]
  CHINESE_WORDS_URI = 'http://chugokugo-script.net/tango/level3/meishi.html'
  
  has_one :sentence
  
  validates :chinese, :japanese,　:pinyin, :level, presence: true

  def self.get_response_message(text)
    if text.include?('新しい単語')
      random_chinese = get_random_chinese(text)
      format_message(random_chinese)
    else
      uri = URI.encode("#{TRANSLATION_ROOT_URI}?text=#{text}&source=#{SOURCE}&target=#{TARGET}")
      translation = get_json_translation(URI.parse(uri))
      format_message(translation['message'])
    end
  end

  private
  def self.get_random_chinese(text)
    level = 1
    if text.include?('2') or text.include?('２')
      level = 2
    elsif text.include?('3') or text.include?('３')
      level = 3
    end

    res = random_chinese_from_db(level)
    message = <<~EOS
      新しい単語：#{res[:word].chinese}
      発音：#{res[:word].pinyin}
      意味：#{res[:word].japanese}
      例文：
    #{res[:sentence].chinese}
    #{res[:sentence].pinyin}
    #{res[:sentence].japanese}
    EOS
    message.chomp
  end

  def self.random_chinese_from_db(level)
    chinese_word = Word.find(Word.where(level:level).pluck(:id).sample)
    chinese_sentence = chinese_word.sentence
    {
      word: chinese_word,
      sentence: chinese_sentence
    }
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
