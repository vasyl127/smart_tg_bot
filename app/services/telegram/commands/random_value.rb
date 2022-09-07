module Telegram
  module Commands
    class RandomValue
      YES_OR_NO = [I18n.t('telegram.messages.random.yes_value'), I18n.t('telegram.messages.random.no_value'),
                   I18n.t('telegram.messages.random.maybe_value')].freeze
      N_VALUE = 10

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

      def show_func
        steps_controller.next_step

        { text: I18n.t('telegram.messages.chose'), keyboard: keyboard.random_value }
      end

      def operations_in_random
        case message
        when keyboard.secondary_keys[:yes_or_no]
          yes_or_no_message
        when keyboard.secondary_keys[:random_in_range]
          random_in_range
        end
      end

      def yes_or_no_message
        { text: YES_OR_NO.sample, keyboard: keyboard.random_value }
      end

      def random_in_range
        { text: (1..N_VALUE).to_a.sample, keyboard: keyboard.random_value }
      end
    end
  end
end
