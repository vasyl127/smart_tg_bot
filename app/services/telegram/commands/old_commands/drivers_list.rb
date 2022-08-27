# frozen_string_literal: true

module Telegram
  module Commands
    class DriversList
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

      def show_drivers
        steps_controller.next_step

        { text: I18n.t('telegram.messages.driver_list'), keyboard: keyboard.drivers_list(drivers) }
      end

      def in_driver # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        store_params.store_value(telegram_id: telegram_id, value: { driver_name: message })
        steps_controller.next_step
        string = { text: prepare_in_driver }
        string.merge! case current_user.role
                      when 'admin'
                        { text: prepare_in_driver, keyboard: keyboard.in_driver_for_admin }
                      when 'trip_manager'
                        { text: prepare_in_driver, keyboard: keyboard.in_driver_for_trip_manager }
                      when 'repair_manager'
                        { text: prepare_in_driver, keyboard: keyboard.in_driver_for_repair_manager }
                      end

        string
      end

      def operation_in_driver # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        case message
        when keyboard.secondary_keys[:delete]
          delete_driver
          { text: I18n.t('telegram.messages.driver_delete'),
            keyboard: keyboard.home_roles_keyboard(current_user.role) }
        when keyboard.primary_keys[:trips_list]
          trips_list
        when keyboard.secondary_keys[:repair_requests]
          { text: repair_request_status, keyboard: keyboard.in_fuel_or_request }
        when keyboard.secondary_keys[:back]
          { text: prepare_in_driver, keyboard: in_driver_keyboard }
        end
      end

      def in_driver_keyboard
        case current_user.role
        when 'admin'
          keyboard.in_driver_for_admin
        when 'repair_manager'
          keyboard.in_driver_for_repair_manager
        when 'tripe_manager'
          keyboard.in_driver_for_trip_manager
        end
      end

      def drivers
        User.where(role: 'driver').pluck(:name)
      end

      def prepare_in_driver
        return errors.blank unless driver.present?

        "👤 #{driver.name}\n🔑 #{driver.token}\n🗓 #{driver.created_at.strftime('%d.%m.%Y')}\n"
      end

      def fuel_status
        return I18n.t('telegram.errors.blank') if driver.fuels.blank?

        string = "#{I18n.t('telegram.messages.fuel')}\n"
        fuels = driver.fuels
        fuels.each do |fuel|
          string += "🗓 #{fuel.created_at.strftime('%d.%m.%Y')}, ⛽ #{fuel.capacity}, 💰 #{fuel.price}\n\n"
        end

        string
      end

      def repair_request_status
        return I18n.t('telegram.errors.blank') if driver.repair_requests.blank?

        string = "#{I18n.t('telegram.messages.repair_request')}\n"
        requests = driver.repair_requests
        requests.each do |request|
          string += "🗓 #{request.created_at.strftime('%d.%m.%Y')}\n🛠 #{request.text}\n\n"
        end

        string
      end

      def trips_list
        steps_controller.start_trips_list
        ::Telegram::Commands::TripsList.new(params).answer
      end

      def driver
        @driver ||= User.find_by(name: message) ||
                    User.find_by(name: store_params.store.dig(telegram_id, :driver_name))
      end

      def delete_driver
        driver.delete if driver.present?
      end
    end
  end
end
