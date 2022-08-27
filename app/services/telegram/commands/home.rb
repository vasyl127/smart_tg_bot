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
        @answer = { text: home_message, keyboard: keyboard.home_roles_keyboard(current_user.role) }
      end

      def home_message # rubocop:disable Metrics/AbcSize
        string = "#{I18n.t('telegram.messages.home')}\n\n"
        # string += "#{I18n.t('telegram.messages.notify')}: #{notifications.count}\n" unless driver?
        # string += "#{I18n.t('telegram.messages.driver_list')}: #{drivers.count}\n" unless driver?
        # string += "#{I18n.t('telegram.messages.manager_list')}: #{managers_count}\n" if admin?
        # string += trips if TRIP_MANAGER.include? current_user.role
        # string += repair_requests if REPAIR_MANAGER.include? current_user.role
        # string += driver_info if driver?
        string += "Bot work time #{bot_work_time}" if admin?

        string
      end

      def bot_work_time
        work_time = Time.now.to_i - store_params.bot_start_time.to_i

        "#{work_time.div(3600)} hours, #{work_time.div(60)} minutes"
      end

      def notifications
        @notifications ||= current_user.notifications
      end

      def admin?
        current_user.role == 'admin'
      end
    end
  end
end
