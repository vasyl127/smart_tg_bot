# frozen_string_literal: true

module Telegram
  module Commands
    class RepairRequest
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params, :keyboard, :current_user,
                  :notification

      def initialize(params)
        @params = params
        @message = params[:message]
        @telegram_id = params[:telegram_id]
        @errors = params[:errors]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @current_user = params[:current_user]
        @notification = params[:notification]

        exec_command
      end

      private

      def exec_command
        @answer = send(steps_controller.current_step)
        steps_controller.next_step
      end

      def fill_name
        { text: I18n.t('telegram.messages.fill_repair_request') }
      end

      def save_name
        create_request
        { text: I18n.t('telegram.messages.repair_request_created'),
          keyboard: keyboard.home_roles_keyboard(current_user.role) }
      end

      def create_request
        value = "#{current_user.name} #{I18n.t('telegram.messages.notify_create_repair')}: #{message}"
        notification.notify_for_repair_managers value
        current_user.repair_requests.create(text: message)
      end
    end
  end
end
