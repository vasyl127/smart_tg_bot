module Telegram
  module Commands
    class ShareCategory
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params, :keyboard, :current_user,
                  :store_params, :notify

      def initialize(params)
        @params = params
        @message = params[:message]
        @telegram_id = params[:telegram_id]
        @errors = params[:errors]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @current_user = params[:current_user]
        @store_params = params[:store_params]
        @notify = params[:notification]

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

      def shared
        store_params.store_value(telegram_id: telegram_id, value: { user_name: message })

        UserCategory.create(user_id: user.id, category_id: category.id) if user.present? && category.present?
        send_notify
        { text: "#{I18n.t('telegram.messages.categories.shared')} #{user.name}",
          keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def send_notify
        return if current_user.blank? || category.blank?

        text = "#{current_user.name} #{I18n.t('telegram.messages.categories.notify')} #{category.name}"
        notify.notify_for_user(user, text)
      end

      def category
        current_user.categories.find_by(name: store_params.store.dig(telegram_id, :category_name))
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
