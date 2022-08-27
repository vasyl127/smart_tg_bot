# frozen_string_literal: true

module Telegram
  class ParseMessage
    attr_reader :params, :message, :store_params, :notification, :message_text, :keyboard

    def initialize(message, store_params, notification, message_text)
      @message = message
      @store_params = store_params
      @notification = notification
      @message_text = message_text
      @keyboard = Telegram::Keyboards.new

      locale
      prepare_params
    end

    def prepare_params
      @params = { message: message_text,
                  errors: ::Telegram::Errors.new,
                  telegram_id: message.chat.id,
                  current_user: current_user,
                  steps_controller: ::Telegram::Steps.new(current_user),
                  keyboard: keyboard,
                  notification: notification,
                  store_params: store_params }
    end

    def answer
      text = ::Telegram::Commands::CommandsController.new(params).answer
      return { text: params[:errors].all_messages } if params[:errors].any?
      return text if text.present?

      { text: I18n.t('telegram.errors.something'),
        keyboard: keyboard.home_roles_keyboard(current_user.role) }
    end

    def current_user
      @current_user ||= User.find_by(telegram_id: message.chat.id)
    end

    def locale
      return if current_user.blank?
      return I18n.locale = current_user.config.locale.to_sym if current_user.config.locale.present?

      I18n.default_locale
    end
  end
end
