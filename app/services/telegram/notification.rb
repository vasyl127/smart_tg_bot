# frozen_string_literal: true

module Telegram
  class Notification
    TOKEN = Figaro.env.telegram_token

    def notify_for_user(user, text)
      user.notifications.create(text: text)
      notify_message(user)
    end

    def notify_for_admins(text)
      admins.each { _1.notifications.create(text: text) }
      notify_messages(admins)
    end

    def notify_message(user)
      message = I18n.t('telegram.messages.notify.new')
      params = { chat_id: user.telegram_id, text: message }
      Telegram::Bot::Client.run(TOKEN) { _1.api.sendMessage(params) } if user.telegram_id.present?
    end

    def notify_messages(users)
      message = I18n.t('telegram.messages.notify.new')
      users.each do |user|
        params = { chat_id: user.telegram_id, text: message }
        Telegram::Bot::Client.run(TOKEN) { _1.api.sendMessage(params) } if user.telegram_id.present?
      end
    end

    def admins
      User.where(role: 'admin')
    end
  end
end
