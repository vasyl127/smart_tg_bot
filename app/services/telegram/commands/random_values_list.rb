module Telegram
  module Commands
    class RandomValuesList
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

      def show_random_values
        if random_values.blank?
          return { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.random_values_list(random_values) }
        end

        { text: show_random_value, keyboard: keyboard.random_values_list(random_values) }
      end

      def in_random_value
        store_params.store_value(telegram_id: telegram_id, value: { random_value_description: message })

        { text: prepare_in_random_value, keyboard: keyboard.in_random_value }
      end

      def operation_in_random_value # rubocop:disable Metrics/AbcSize
        case message
        when keyboard.secondary_keys[:delete]
          delete_random_value
          steps_controller.random_values_list
          { text: show_random_value, keyboard: keyboard.random_values_list(random_values) }
        when keyboard.secondary_keys[:back]
          steps_controller.random_values_list
          { text: show_random_value, keyboard: keyboard.random_values_list(random_values) }
        end
      end

      def show_random_value
        value = store_params.store&.dig(telegram_id, :random_value)

        return I18n.t('telegram.messages.random.name') if value.blank?

        "#{I18n.t('telegram.messages.random.saved')}\n 🔑#{value}\n"
      end

      def prepare_in_random_value
        return errors.blank if random_value.blank?

        "📄 #{random_value.description}\n📆 #{random_value.created_at.strftime('%m.%d.%Y')}\n🔑 #{random_value.value}\n"
      end

      def delete_random_value
        random_value.destroy
      end

      def random_values
        @random_values ||= current_user.random_values
      end

      def random_value
        @random_value ||= current_user.random_values
                                      .find_by(description: store_params.store
                                                                        .dig(telegram_id, :random_value_description))
      end
    end
  end
end
