# frozen_string_literal: true

class BotController
  attr_reader :answer, :store_params, :notification

  def initialize(notification:)
    @notification = notification
    @store_params = ::Telegram::Storage.new
  end

  def parse_message(message)
    @answer = if authorized?(message.chat.id)
                ::Telegram::ParseMessage.new(message, store_params, notification, message_text(message)).answer
              else
                ::Telegram::Authorize.new(message, message_text(message)).answer
              end
  end

  def authorized?(telegram_id)
    current_user(telegram_id).present?
  end

  def current_user(telegram_id)
    User.find_by(telegram_id: telegram_id)
  end

  def message_text(message)
    return message.text if message.methods.include? :text

    ''
  end
end
