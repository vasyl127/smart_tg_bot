module Telegram
  module Commands
    class AddRandomValue
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

        { text: I18n.t('telegram.messages.random.add') }
      end

      def save_random_value
        current_user.random_values.create(value_params) if message.present?
        store_params.store_value(telegram_id: telegram_id, value: { random_value: random_value })
        steps_controller.random_values_list

        ::Telegram::Commands::RandomValuesList.new(params).answer
      end

      def value_params
        { description: message, value: random_value }
      end

      def random_value
        @random_value ||= SecureRandom.hex(8)
      end
    end
  end
end
