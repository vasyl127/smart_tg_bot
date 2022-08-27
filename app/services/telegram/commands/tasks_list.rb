module Telegram
  module Commands
    class TasksList
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

      def show_tasks
        return { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.objects_name_list(tasks) } if tasks.blank?

        { text: I18n.t('telegram.messages.tasks.name'), keyboard: keyboard.objects_name_list(tasks) }
      end

      def in_task
        store_params.store_value(telegram_id: telegram_id, value: { task_name: message })

        { text: prepare_in_task, keyboard: keyboard.in_task }
      end

      def operation_in_task
        case message
        when keyboard.secondary_keys[:delete]
          delete_task
        when keyboard.secondary_keys[:back]
          steps_controller.tasks_list
          { text: I18n.t('telegram.messages.tasks.name'), keyboard: keyboard.objects_name_list(tasks) }
        end
      end

      def prepare_in_task
        return errors.blank if task.blank?

        "💼 #{task.name}\n🗓 #{task.created_at.strftime('%d.%m.%Y')}\n"
      end

      def delete_task
        task.destroy

        { text: I18n.t('telegram.messages.tasks.deleted'), keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def task
        current_user.tasks.find_by(name: store_params.store.dig(telegram_id, :task_name))
      end

      def tasks
        @tasks = current_user.tasks
      end
    end
  end
end
