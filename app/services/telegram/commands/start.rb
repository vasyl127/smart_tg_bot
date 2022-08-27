# frozen_string_literal: true

module Telegram
  module Commands
    class Start
      attr_reader :params, :message, :errors, :telegram_id, :steps_controller, :keyboard, :store_params, :answer,
                  :current_user

      def initialize(params)
        @params = params
        @message = params[:message]
        @errors = params[:errors]
        @current_user = params[:current_user]
        @telegram_id = params[:telegram_id]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @store_params = params[:store_params]

        exec_command
      end

      def exec_command
        @answer = if current_user.present?
                    hello_message
                  else
                    errors.add_errors(I18n.t('telegram.errors.user_absent'))
                  end
      end

      def hello_message
        { text: "#{current_user.name}, #{I18n.t('telegram.messages.start')}",
          keyboard: keyboard.home_roles_keyboard(current_user.role) }
      end
    end
  end
end
