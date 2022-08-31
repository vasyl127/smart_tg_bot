module Telegram
  module Commands
    class AddCategory
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

        { text: I18n.t('telegram.messages.categories.add') }
      end

      def save_category
        current_user.categories.create(name: message) if message.present?
        steps_controller.categories_list
        steps_controller.next_step

        ::Telegram::Commands::CategoriesList.new(params).answer
        # { text: I18n.t('telegram.messages.categories.saved'),
        #   keyboard: keyboard.home_keyboard(current_user.role) }
      end
    end
  end
end
