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
          # root = 'https://script.google.com/macros/s/AKfycbxG6-C7q0DENFz0oleSQc6P8C9jR3GDzZZx844KIv3R4KEuvD4/exec'
          # res = Net::HTTP.get(root, '?text='+event.message['text']+'&source=ja&target=zh-cn')
          path = 'https://script.google.com/macros/s/AKfycbyw6X1KtmmNZ2IrueEvxF0yYZAXxd23-1XzY-m7fFVCSqVpqts/exec'
          params = {text: 'hello', source: 'en', target: 'ja'}
          headers = {timeout: 3000}
          res = get_via_redirect(path, params, headers)
          message = {
            type: 'text',
            text: res.message
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
end
