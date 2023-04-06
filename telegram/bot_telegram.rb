# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'

class BotTelegram
  TOKEN = ENV.fetch('TELEGRAM_TOKEN') || Figaro.env.telegram_token

  attr_reader :bot_controller, :notification

  def initialize
    @notification = ::Telegram::Notification.new
    @bot_controller = ::BotController.new(notification: notification)
  end

  def run
    puts '-------------Bot started-------------'
    bot.listen do |message|
      bot_controller.parse_message(message)
      send_message(message.chat.id, bot_controller.answer)
    rescue StandardError => e
      logger(message: message, errors: e)
    end
  end

  private

  def bot
    Telegram::Bot::Client.run(TOKEN) { |bot| return bot }
  end

  def send_message(chat_id, answer)
    message = answer[:text]
    kb = answer[:keyboard]
    return bot.api.sendMessage(chat_id: chat_id, text: message) if kb.blank?

    bot.api.sendMessage(chat_id: chat_id, text: message, reply_markup: kb)
  end

  def logger(message:, errors:)
    model = Error.create(telegram_id: message.chat.id,
                         name: message.chat.first_name,
                         error: errors,
                         error_full_message: errors.full_message)
    model.update(message: message.text) if message.methods.include? :text
    text = "#{I18n.t('telegram.errors.new_errors')} #{model.id}"
    notification.notify_for_admins(text)
    puts text
  end
end
