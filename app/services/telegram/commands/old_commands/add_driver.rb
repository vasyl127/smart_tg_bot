# frozen_string_literal: true

module Telegram
  module Commands
    class AddDriver
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params, :keyboard, :current_user

      def initialize(params)
        @params = params
        @message = params[:message]
        @telegram_id = params[:telegram_id]
        @errors = params[:errors]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @current_user = params[:current_user]

        exec_command
      end

      private

      def exec_command
        @answer = send(steps_controller.current_step)
        steps_controller.next_step
      end

      def fill_name
        { text: I18n.t('telegram.messages.driver_name') }
      end

      def save_name
        token = SecureRandom.hex(5)
        User.create(name: message, token: token, role: 'driver')

        { text: "Driver #{message} created, token:\n\n#{token}",
          keyboard: keyboard.home_keyboard(current_user.role) }
      end
    end
  end
end
