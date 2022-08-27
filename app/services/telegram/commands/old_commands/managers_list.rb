# frozen_string_literal: true

module Telegram
  module Commands
    class ManagersList
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

      def show_managers
        { text: I18n.t('telegram.messages.manager_list'), keyboard: keyboard.managers_list(managers) }
      end

      def in_manager
        store_params.store_value(telegram_id: telegram_id, value: { manager_name: message })

        { text: prepare_in_manager, keyboard: keyboard.in_manager_keyboard }
      end

      def operation_in_manager
        return unless keyboard.secondary_keys[:delete]

        delete_manager
        { text: I18n.t('telegram.messages.manager_delete'),
          keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def managers
        User.where("role LIKE 'repair_manager' OR role LIKE 'trip_manager'").pluck(:name)
      end

      def manager
        @manager ||= User.find_by(name: message) ||
                     User.find_by(name: store_params.store.dig(telegram_id, :manager_name))
      end

      def prepare_in_manager
        return errors.blank unless manager.present?

        role = case manager.role
               when 'repair_manager'
                 '🛠'
               when 'trip_manager'
                 '🚚'
               end
        "#{role} #{manager.name}\n🔑 #{manager.token}\n🗓 #{manager.created_at.strftime('%d.%m.%Y')}\n"
      end

      def delete_manager
        manager.delete if manager.present?
      end
    end
  end
end
