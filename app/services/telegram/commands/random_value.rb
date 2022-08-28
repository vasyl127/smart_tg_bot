module Telegram
  module Commands
    class RandomValue
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

      def generate_value
        steps_controller.next_step

        { text: SecureRandom.hex(8), keyboard: keyboard.home_keyboard(current_user.role) }
      end
    end
  end
end
