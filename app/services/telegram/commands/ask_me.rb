

module Telegram
  module Commands
    class AskMe
      API_KEY = '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'.freeze

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

      def start_massage
        steps_controller.next_step
        { text: I18n.t('telegram.messages.ask_me_start'),
          keyboard: keyboard.ask_me_keyboard }
      end

      def question
        answer = AskMeService.new(message).generate_answer

        { text: answer, keyboard: keyboard.ask_me_keyboard }
      end
    end
  end
end