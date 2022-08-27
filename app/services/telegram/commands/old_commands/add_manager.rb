# frozen_string_literal: true

module Telegram
  module Commands
    class AddManager
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

      def fill_name
        { text: I18n.t('telegram.messages.manager_name') }
      end

      def choose_manager_role
        store_params.store_value(telegram_id: telegram_id, value: { manager_name: message })
        { text: I18n.t('telegram.messages.manager_role'), keyboard: keyboard.choose_manager_role }
      end

      def save_name # rubocop:disable Metrics/AbcSize
        token = SecureRandom.hex(5)
        role = case message
               when keyboard.secondary_keys[:repair_manager]
                 'repair_manager'
               when keyboard.secondary_keys[:trip_manager]
                 'trip_manager'
               end
        User.create(name: store_params.store.dig(telegram_id, :manager_name), role: role, token: token)
        { text: "#{I18n.t('telegram.messages.manager_created')}\n\n#{token}",
          keyboard: keyboard.home_keyboard(current_user.role) }
      end
    end
  end
end
