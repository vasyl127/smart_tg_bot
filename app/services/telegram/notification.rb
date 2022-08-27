# frozen_string_literal: true

module Telegram
  class Notification
    TOKEN = Figaro.env.telegram_token
    TRIP_MANAGER = %w[trip_manager admin].freeze
    REPAIR_MANAGER = %w[repair_manager admin].freeze
    ADMIN = %w[admin].freeze

    def notify_for_trip_managers(text)
      trip_managers.each { _1.notifications.create(text: text) }
      new_notify_message(trip_managers)
    end

    def notify_for_repair_managers(text)
      repair_managers.each { _1.notifications.create(text: text) }
      new_notify_message(repair_managers)
    end

    def notify_for_admin(text)
      admins.each { _1.notifications.create(text: text) }
      new_notify_message(admins)
    end

    def new_notify_message(users)
      message = I18n.t('telegram.messages.notify.new')
      users.each do |user|
        params = { chat_id: user.telegram_id, text: message }
        Telegram::Bot::Client.run(TOKEN) { _1.api.sendMessage(params) } if user.telegram_id.present?
      end
    end

    def trip_managers
      User.where(role: TRIP_MANAGER)
    end

    def repair_managers
      User.where(role: REPAIR_MANAGER)
    end

    def admins
      User.where(role: ADMIN)
    end
  end
end
