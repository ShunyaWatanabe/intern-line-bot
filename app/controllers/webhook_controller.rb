require 'line/bot'
require 'net/http'
require 'nokogiri'
require 'open-uri'

class WebhookController < ApplicationController
  SOURCE = 'ja'
  TARGET = 'zh-cn'
  TRANSLATION_ROOT_URI = ENV["TRANSLATION_ROOT_URI"]
  CHINESE_WORDS_URI = 'http://chugokugo-script.net/tango/level3/meishi.html'
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
          res = Word.get_response_message(event.message['text'])
          # res = get_response_message(event.message['text'])
          client.reply_message(event['replyToken'], res)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
    head :ok
  end
end
