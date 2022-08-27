# frozen_string_literal: true

module Telegram
  module Commands
    class TripsList
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

      def trips_list
        steps_controller.next_step
        return { text: I18n.t('telegram.messages.trip.trips'), keyboard: keyboard.trips_list(trips) } if trips.present?

        { text: I18n.t('telegram.errors.blank'), keyboard: keyboard.trips_list(trips) }
      end

      def in_trip
        store_params.store_value(telegram_id: telegram_id, value: { list_number: message })
        steps_controller.next_step

        { text: prepare_in_trip, keyboard: keyboard.in_trip }
      end

      def operation_in_trip # rubocop:disable Metrics/AbcSize
        case message
        when keyboard.secondary_keys[:delete]
          delete_trip
        when keyboard.secondary_keys[:fuel]
          { text: fuel_status, keyboard: keyboard.in_fuel }
        when keyboard.secondary_keys[:back]
          { text: prepare_in_trip, keyboard: keyboard.in_trip }
        end
      end

      def fuel_status
        return I18n.t('telegram.errors.blank') if trip.fuels.blank?

        string = "#{I18n.t('telegram.messages.fuel')}\n"
        fuels = trip.fuels
        fuels.each do |fuel|
          string += "🗓 #{fuel.created_at.strftime('%d.%m.%Y')}, ⛽ #{fuel.capacity}, 💰 #{fuel.price}\n\n"
        end

        string
      end

      def prepare_in_trip # rubocop:disable Metrics/AbcSize
        return errors.blank unless trip.present?

        string = "#{I18n.t('telegram.messages.trip.list_number')}: #{trip.list_number}\n"
        string += "#{I18n.t('telegram.messages.trip.shops')}: #{trip.shops}\n"
        string += "#{I18n.t('telegram.messages.trip.distance')}: #{trip.distance}\n"
        string += "#{I18n.t('telegram.messages.trip.weight')}: #{trip.weight}\n"
        string += "#{I18n.t('telegram.messages.trip.pallets')}: #{trip.pallets}\n"
        string += "#{I18n.t('telegram.messages.trip.date')}: #{trip.created_at.strftime('%m.%d.%Y %H:%M')}\n"

        string
      end

      def delete_trip
        steps_controller.next_step
        trip.update(deleted_at: Time.now)
        { text: I18n.t('telegram.messages.trip.deleted'),
          keyboard: keyboard.home_roles_keyboard(current_user.role) }
      end

      def trip # rubocop:disable Metrics/AbcSize
        @trip ||= if current_user.role == 'driver'
                    current_user.trips.find_by(list_number: message) ||
                      current_user.trips.find_by(list_number: store_params.store.dig(telegram_id, :list_number))
                  else
                    user = User.find_by(name: store_params.store.dig(telegram_id, :driver_name))
                    user.trips.find_by(list_number: store_params.store.dig(telegram_id, :list_number))
                  end
      end

      def trips
        return @trips ||= current_user.trips.where(deleted_at: nil) if current_user.role == 'driver'

        @trips ||= User.find_by(name: store_params.store.dig(telegram_id, :driver_name)).trips.where(deleted_at: nil)
      end
    end
  end
end
