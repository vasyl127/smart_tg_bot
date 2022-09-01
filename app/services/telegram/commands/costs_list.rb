module Telegram
  module Commands
    class CostsList
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

      def show_costs
        return { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.costs_list(costs) } if costs.blank?

        { text: I18n.t('telegram.messages.costs.name'), keyboard: keyboard.costs_list(costs) }
      end

      def in_cost
        return go_to_category if message == keyboard.secondary_keys[:back]

        store_params.store_value(telegram_id: telegram_id, value: { cost_name: message })

        { text: prepare_in_cost, keyboard: keyboard.in_cost }
      end

      def operation_in_cost
        case message
        when keyboard.secondary_keys[:delete]
          delete_cost
        when keyboard.secondary_keys[:back]
          steps_controller.costs_list
          { text: I18n.t('telegram.messages.costs.name'), keyboard: keyboard.costs_list(costs) }
        end
      end

      def prepare_in_cost
        return errors.blank if cost.blank?

        "📄 #{cost.name}\n📆 #{cost.created_at.strftime('%m.%d.%Y')}\n💸 #{cost.value}\n"
      end

      def delete_cost
        cost.destroy

        go_to_category
      end

      def go_to_category
        steps_controller.categories_list
        steps_controller.next_step

        ::Telegram::Commands::CategoriesList.new(params).answer
      end

      def category
        @category ||= current_user.categories.find_by(name: store_params.store.dig(telegram_id, :category_name))
      end

      def categories
        @categories = current_user.categories
      end

      def costs
        @costs ||= category.costs
      end

      def cost
        @cost ||= category.costs.find_by(name: store_params.store.dig(telegram_id, :cost_name))
      end
    end
  end
end
