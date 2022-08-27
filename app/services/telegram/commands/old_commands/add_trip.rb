# frozen_string_literal: true

module Telegram
  module Commands
    class AddTrip
      attr_reader :answer, :message, :telegram_id, :errors, :steps_controller, :params, :keyboard,
                  :current_user, :store_params, :notification

      def initialize(params)
        @params = params
        @message = params[:message]
        @telegram_id = params[:telegram_id]
        @errors = params[:errors]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @current_user = params[:current_user]
        @store_params = params[:store_params]
        @notification = params[:notification]

        exec_command
      end

      private

      def exec_command
        @answer = send(steps_controller.current_step)
      end

      def list_number
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_list_number') }
      end

      def shops
        store_params.store_value(telegram_id: telegram_id, value: { list_number: message })
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_shops') }
      end

      def distance
        store_params.store_value(telegram_id: telegram_id, value: { shops: message })
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_distance') }
      end

      def weight
        store_params.store_value(telegram_id: telegram_id, value: { distance: message })
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_weight') }
      end

      def pallets
        store_params.store_value(telegram_id: telegram_id, value: { weight: message })
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_pallets') }
      end

      def save_trip # rubocop:disable Metrics/AbcSize
        store_params.store_value(telegram_id: telegram_id, value: { pallets: message })
        trip_params = store_params.store[telegram_id].slice(:list_number, :shops, :distance, :weight, :pallets)
        create_trip(trip_params)
        steps_controller.start_trips_list
        steps_controller.next_step
        { text: I18n.t('telegram.messages.trip.fill_created'),
          keyboard: keyboard.trips_list(trips_list) }
      end

      def trips_list
        return current_user.trips.where(deleted_at: nil) if current_user.role == 'driver'

        User.find_by(name: store_params.store.dig(telegram_id, :driver_name)).trips.where(deleted_at: nil)
      end

      def create_trip(trip_params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        case current_user.role
        when 'driver'
          current_user.trips.create(trip_params)
          value = "#{current_user.name} #{I18n.t('telegram.messages.notify_create_trip')} #{trip_params[:list_number]}"
          notification.notify_for_trip_managers value
        when 'admin'
          user = User.find_by(name: store_params.store.dig(telegram_id, :driver_name))
          user.trips.create(trip_params)
        when 'trip_manager'
          user = User.find_by(name: store_params.store.dig(telegram_id, :driver_name))
          user.trips.create(trip_params)
        end
      end
    end
  end
end
