module Telegram
  module Commands
    class AddCost
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

        { text: I18n.t('telegram.messages.costs.add') }
      end

      def save_cost
        category.costs.create(cost_params) if message.present?

        { text: I18n.t('telegram.messages.costs.saved'),
          keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def cost_params
        if message.include?(':')
          value = message.split(':')
          { name: value.first, value: value.last }
        else
          { name: message }
        end
      end

      def category
        current_user.categories.find_by(name: store_params.store.dig(telegram_id, :category_name))
      end
    end
  end
end
