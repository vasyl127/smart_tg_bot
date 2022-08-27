# frozen_string_literal: true

module Telegram
  class Authorize
    attr_reader :telegram_id, :text, :answer

    def initialize(message, text)
      @telegram_id = message.chat.id
      @text = text

      @answer = authorize
    end

    def authorize
      return { text: I18n.t('telegram.messages.authorize.fill_token') } if text == '/start'
      return { text: I18n.t('telegram.errors.incorect_token') } unless user_by_token.present?

      user_by_token.update(telegram_id: telegram_id)
      { text: I18n.t('telegram.messages.authorize.success'),
        keyboard: ::Telegram::Keyboards.new.home_keyboard(user_by_token.role) }
    end

    def user_by_token
      @user_by_token ||= User.find_by(token: text)
    end
  end
end
