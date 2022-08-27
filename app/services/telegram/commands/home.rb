# frozen_string_literal: true

module Telegram
  module Commands
    class Home
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params, :keyboard, :current_user,
                  :store_params

      def initialize(params)
        @params = params
        @message = params[:message]
        @telegram_id = params[:telegram_id]
        @errors = params[:errors]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @current_user = params[:current_user]
        @store_params = params[:store_params]

        exec_command
      end

      private

      def exec_command
        @answer = { text: home_message, keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def home_message # rubocop:disable Metrics/AbcSize
        string = "#{I18n.t('telegram.messages.home.name')}\n\n"
        string += "#{I18n.t('telegram.messages.bot.work_time')}: #{bot_work_time}\n" if admin?
        string += "#{I18n.t('telegram.messages.users.name')}: #{users_count}\n" if admin?
        string += "#{I18n.t('telegram.messages.notify.name')}: #{notifications_count}\n"
        string += "#{I18n.t('telegram.messages.tasks.name')}: #{tasks_count}\n"
        string += "#{I18n.t('telegram.messages.categories.name')}: #{categories_count}\n"

        string
      end

      def bot_work_time
        work_time = Time.now.to_i - store_params.bot_start_time.to_i

        "#{work_time.div(3600)} h, #{work_time.div(60)} m"
      end

      def users_count
        User.all.count
      end

      def tasks_count
        current_user.tasks.count
      end

      def categories_count
        current_user.categories.count
      end

      def notifications_count
        current_user.notifications.count
      end

      def admin?
        current_user.role == 'admin'
      end
    end
  end
end
