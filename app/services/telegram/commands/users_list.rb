module Telegram
  module Commands
    class UsersList
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

      def show_users
        return { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.users_list(users) } if users.blank?

        { text: I18n.t('telegram.messages.users.name'), keyboard: keyboard.users_list(users) }
      end

      def in_user
        store_params.store_value(telegram_id: telegram_id, value: { user_name: message })

        { text: prepare_in_user, keyboard: keyboard.in_user }
      end

      def operation_in_user
        case message
        when keyboard.secondary_keys[:delete]
          delete_user
        when keyboard.secondary_keys[:back]
          steps_controller.users_list
          { text: I18n.t('telegram.messages.users.name'), keyboard: keyboard.users_list(users) }
        end
      end

      def prepare_in_user
        return errors.blank if user.blank?

        "💼 #{user.name}\n🔑 #{user.token}\n🗓 #{user.created_at.strftime('%d.%m.%Y')}\n"
      end

      def delete_user
        user.destroy

        { text: I18n.t('telegram.messages.users.deleted'), keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def user
        User.find_by(name: store_params.store.dig(telegram_id, :user_name))
      end

      def users
        @users = User.without(current_user)
      end
    end
  end
end
