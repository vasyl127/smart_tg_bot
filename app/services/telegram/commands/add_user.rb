module Telegram
  module Commands
    class AddUser
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
      end

      def fill_name
        steps_controller.next_step

        { text: I18n.t('telegram.messages.users.add') }
      end

      def save_users
        User.create(name: message, token: SecureRandom.hex(8)) if message.present?

        { text: I18n.t('telegram.messages.users.saved'),
          keyboard: keyboard.home_keyboard(current_user.role) }
      end
    end
  end
end
