require 'line/bot'
require 'net/http'
require 'nokogiri'
require 'open-uri'

class WebhookController < ApplicationController
  SOURCE = 'ja'
  TARGET = 'zh-cn'
  ROOT = ENV["TRANSLATION_ROOT_URI"]
  CHINESE_URI = 'http://chugokugo-script.net/tango/level3/meishi.html'
  protect_from_forgery except: [:callback] # CSRF対策無効化

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head 470
    end

    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          case event.message['text']
          when '新しい単語'
            message = get_random_chinese()
            client.reply_message(event['replyToken'], format_message(message))
          else
            uri = URI.encode("#{ROOT}?text=#{event.message['text']}&source=#{SOURCE}&target=#{TARGET}")
            res = get_json_translation(URI.parse(uri))
            client.reply_message(event['replyToken'], format_message(res['message']))
          end
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
    head :ok
  end

  private
  def get_random_chinese()
    charset = nil
    html = open(CHINESE_URI) do |f|
      charset = f.charset
      f.read
    end    
    
    # 文字化け対応
    if charset == "iso-8859-1"
      charset = html.scan(/charset="?([^\s"]*)/i).first.join
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    lines = doc.xpath('//section/div[@class="divBunruiBox"]')
    rand_num = rand(lines.count)
    rand_line = lines[rand_num]

    chinese_word = rand_line.css('.divBunruiC').inner_text
    pinyin_word = rand_line.css('.divBunruiP').inner_text
    japanese_word = rand_line.css('.divBunruiN').inner_text
    chinese_sentence = rand_line.css('.divBunruiExC').inner_text
    pinyin_sentence = rand_line.css('.divBunruiExP').inner_text
    japanese_sentence = rand_line.css('.divBunruiExN').inner_text
    
    "新しい単語：#{chinese_word}\n発音：#{pinyin_word}\n意味：#{japanese_word}\n例文：\n\t#{chinese_sentence}\n\t#{pinyin_sentence}\n\t#{japanese_sentence}"
  end

  def format_message(message)
    {
      type: 'text',
      text: message
    }
  end

  def get_translation(uri)
    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPRedirection
      get_translation(URI.parse(response["location"]))
    else
      response.body
    end
  end

  def get_json_translation(uri)
    JSON.parse(get_translation(uri)) # -> レスポンスをjsonで変換して返してくれる
  end
end
