module Telegram
  module Commands
    class CategoriesList
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

      def show_categories
        return { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.categories_list(categories) } if categories.blank?

        { text: I18n.t('telegram.messages.categories.name'), keyboard: keyboard.categories_list(categories) }
      end

      def in_category
        store_params.store_value(telegram_id: telegram_id, value: { category_name: message })

        { text: prepare_in_category, keyboard: keyboard.in_category }
      end

      def operation_in_category
        case message
        when keyboard.secondary_keys[:delete]
          delete_category
        when keyboard.secondary_keys[:back]
          steps_controller.categories_list
          { text: I18n.t('telegram.messages.categories.name'), keyboard: keyboard.categories_list(categories) }
        end
      end

      def prepare_in_category
        return errors.blank if category.blank?

        string = "📄 #{category.name}\n📆 #{category.created_at.strftime('%m.%d.%Y')}\n\n"
        costs.each { |cost| string += "📈 #{cost.name} : #{cost.value}💸\n" } if costs.present?
        string += "\n#{I18n.t('telegram.messages.total')}: #{costs_total}💸"

        string
      end

      def delete_category
        category.destroy

        { text: I18n.t('telegram.messages.categories.deleted'), keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def category
        current_user.categories.find_by(name: store_params.store.dig(telegram_id, :category_name))
      end

      def categories
        @categories = current_user.categories
      end

      def costs
        @costs ||= category.costs
      end

      def costs_total
        costs.pluck(:value).map(&:to_d).sum
      end
    end
  end
end
