# frozen_string_literal: true

module Telegram
  module Commands
    class Notifications
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
        @answer = send(steps_controller.current_step)
        steps_controller.next_step
      end

      def notify_list
        { text: prepare_notify, keyboard: keyboard.notifications_list }
      end

      def operation_in_notify
        return delete_all_notify if message == keyboard.secondary_keys[:delete_all]
      end

      def prepare_notify
        return I18n.t('telegram.messages.blank') if notifications.blank?

        string = ''
        notifications.each { |notify| string += "- #{notify.text}\n\n" }

        string
      end

      def delete_all_notify
        notifications.delete_all if notifications.present?

        { text: I18n.t('telegram.messages.notify_deleted'),
          keyboard: keyboard.home_roles_keyboard(current_user.role) }
      end

      def notifications
        @notifications ||= current_user.notifications
      end
    end
  end
end
