require 'line/bot'
require 'net/http'

class WebhookController < ApplicationController
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
          root = 'https://script.google.com/macros/s/AKfycbyw6X1KtmmNZ2IrueEvxF0yYZAXxd23-1XzY-m7fFVCSqVpqts/exec?text='
          url = URI.encode(root+event.message['text']+'&source=ja&target=zh-cn')
          res = get_translation(URI.parse(url))
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
      puts "here"
      get_translation(URI.parse(response["location"]))
    else
      puts response.body
      JSON.parse(response.body)
    end
  end
end
