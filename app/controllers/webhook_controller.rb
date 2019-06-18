require 'line/bot'
require 'net/http'

class WebhookController < ApplicationController
  SOURCE = 'ja'
  TARGET = 'zh-cn'
  ROOT = ENV["TRANSLATION_ROOT_URI"]
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
          uri = URI.encode("#{ROOT}?text=#{event.message['text']}&source=#{SOURCE}&target=#{TARGET}")
          res = get_json_translation(URI.parse(uri))
          message = {
            type: 'text',
            text: res['message']
          }
          client.reply_message(event['replyToken'], message)
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
