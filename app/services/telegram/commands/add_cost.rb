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
        category.costs.create(cost_params) if message.present? && costs.present?
        steps_controller.categories_list
        steps_controller.next_step

        ::Telegram::Commands::CategoriesList.new(params).answer
        # { text: "#{I18n.t('telegram.messages.costs.saved')}\n\n#{prepare_in_category}",
        #   keyboard: keyboard.in_category }
      end

      def cost_params
        if message.include?(':')
          value = message.split(':')
          { name: value.first, value: value.last }
        else
          { name: message }
        end
      end

      def prepare_in_category # rubocop:disable Metrics/AbcSize
        return errors.blank if category.blank?

        string = "📄 #{category.name}\n📆 #{category.created_at.strftime('%m.%d.%Y')}\n\n"
        costs.each { |cost| string += "📈 #{cost.name} : #{cost.value}💸\n" } if costs.present?
        string += "\n#{I18n.t('telegram.messages.total')}: #{costs_total}💸"

        string
      end

      def category
        @category ||= current_user.categories.find_by(name: store_params.store.dig(telegram_id, :category_name))
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
