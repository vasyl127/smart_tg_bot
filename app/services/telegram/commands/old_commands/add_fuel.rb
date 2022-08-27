# frozen_string_literal: true

module Telegram
  module Commands
    class AddFuel
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params,
                  :keyboard, :current_user, :store_params

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

      def fill_capacity
        steps_controller.next_step

        { text: I18n.t('telegram.messages.fuel_capacity') }
      end

      def fill_price
        store_params.store_value(telegram_id: telegram_id, value: { capacity: message })
        steps_controller.next_step

        { text: I18n.t('telegram.messages.fuel_price') }
      end

      def save_data
        store_params.store_value(telegram_id: telegram_id, value: { price: message })
        fuel_params = store_params.store[telegram_id].slice(:capacity, :price)
        create_fuel(fuel_params)

        { text: I18n.t('telegram.messages.fuel_save'),
          keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def create_fuel(fuel_params)
        return steps_controller.start_add_fuel unless Telegram::Validators::Fuel.new(fuel_params, errors).valid?

        trip.fuels.create(fuel_params) if trip.present?
        steps_controller.next_step
      end

      def trip # rubocop:disable Metrics/AbcSize
        @trip ||= if current_user.role == 'driver'
                    current_user.trips.find_by(list_number: store_params.store.dig(telegram_id, :list_number))
                  else
                    user = User.find_by(name: store_params.store.dig(telegram_id, :driver_name))
                    user.trips.find_by(list_number: store_params.store.dig(telegram_id, :list_number))
                  end
      end
    end
  end
end
