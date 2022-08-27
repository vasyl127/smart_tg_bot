# frozen_string_literal: true

module Telegram
  module Commands
    class CommandsController
      ADD_DRIVERS_AND_DRIVERS_LIST = %w[admin trip_manager repair_manager].freeze
      ADD_MENEGERS_AND_MENEGERS_LIST = %w[admin].freeze

      attr_reader :params, :message, :errors, :telegram_id, :steps_controller, :keyboard, :store_params, :answer,
                  :current_user

      def initialize(params)
        @params = params
        @message = params[:message]
        @current_user = params[:current_user]
        @errors = params[:errors]
        @telegram_id = params[:telegram_id]
        @steps_controller = params[:steps_controller]
        @keyboard = params[:keyboard]
        @store_params = params[:store_params]

        exec_command
      end

      private

      def exec_command
        @answer = if it_is_command? || message == '/start'
                    send normalize_command
                  else
                    send steps_controller.steps_list_name.downcase
                  end
      end

      def it_is_command?
        keyboard.primary_keys.values.include? message
      end

      def normalize_command
        return message.delete('/') if message == '/start'

        keyboard.primary_keys.key(message)
      end

      def start
        steps_controller.default_steps if it_is_command?
        ::Telegram::Commands::Start.new(params).answer
      end

      def home
        steps_controller.default_steps if it_is_command?
        ::Telegram::Commands::Home.new(params).answer
      end

      def language
        steps_controller.start_language_set if it_is_command?
        ::Telegram::Commands::LanguageSet.new(params).answer
      end

      def notifications
        steps_controller.start_notifications if it_is_command?
        ::Telegram::Commands::Notifications.new(params).answer
      end
    end
  end
end

# def add_driver
#   return errors.not_permission unless ADD_DRIVERS_AND_DRIVERS_LIST.include? current_user.role

#   steps_controller.start_add_driver if it_is_command?
#   ::Telegram::Commands::AddDriver.new(params).answer
# end

# def add_manager
#   return errors.not_permission unless ADD_MENEGERS_AND_MENEGERS_LIST.include? current_user.role

#   steps_controller.start_add_manager if it_is_command?
#   ::Telegram::Commands::AddManager.new(params).answer
# end

# def drivers_list
#   return errors.not_permission unless ADD_DRIVERS_AND_DRIVERS_LIST.include? current_user.role

#   steps_controller.start_drivers_list if it_is_command?
#   ::Telegram::Commands::DriversList.new(params).answer
# end

# def managers_list
#   return errors.not_permission unless ADD_MENEGERS_AND_MENEGERS_LIST.include? current_user.role

#   steps_controller.start_managers_list if it_is_command?
#   ::Telegram::Commands::ManagersList.new(params).answer
# end

# def add_fuel
#   steps_controller.start_add_fuel if it_is_command?
#   ::Telegram::Commands::AddFuel.new(params).answer
# end

# def repair_request
#   steps_controller.start_repair_request if it_is_command?
#   ::Telegram::Commands::RepairRequest.new(params).answer
# end

# def add_trip
#   steps_controller.start_add_trip if it_is_command?
#   ::Telegram::Commands::AddTrip.new(params).answer
# end

# def trips_list
#   steps_controller.start_trips_list if it_is_command?
#   ::Telegram::Commands::TripsList.new(params).answer
# end
