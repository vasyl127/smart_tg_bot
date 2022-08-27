# frozen_string_literal: true

module Telegram
  class Steps
    HOME              = { list_name: 'HOME', steps_list: %w[home_screen] }.freeze
    LANGUAGE          = { list_name: 'LANGUAGE', steps_list: %w[language_list language_set] }.freeze
    NOTIFICATIONS     = { list_name: 'NOTIFICATIONS', steps_list: %w[notify_list operation_in_notify] }.freeze

    attr_reader :current_user, :current_step, :steps, :steps_list_name

    def initialize(current_user)
      @current_user = current_user
      default_steps if current_user.config.telegram_step.blank?
      params = eval(current_user.config.telegram_step)
      @current_step = params[:current_step]
      @steps_list_name = params[:list_name].upcase
      @steps = self.class.const_get(steps_list_name)[:steps_list]
    end

    def default_steps
      first_step HOME
    end

    def notifications
      first_step NOTIFICATIONS
    end

    def language
      first_step LANGUAGE
    end

    def next_step
      steps.each_with_index do |step, i|
        next unless step == current_step

        next_element = steps[i + 1]
        if next_element.nil?
          default_steps
        else
          update_params(current_step: next_element, list_name: steps_list_name, steps_list: steps)
        end
        break
      end
    end

    private

    def first_step(const)
      @steps = const[:steps_list]
      update_params(current_step: steps.first,
                    list_name: const[:list_name],
                    steps_list: const[:steps_list])
    end

    def update_params(current_step:, list_name:, steps_list:)
      @current_step = current_step
      @steps_list_name = list_name
      @steps = steps_list
      update_user_step(current_step: current_step, list_name: list_name)
    end

    def update_user_step(current_step:, list_name:)
      telegram_step = { current_step: current_step, list_name: list_name }
      current_user.config.update(telegram_step: telegram_step)
    end
  end
end

# ADD_DRIVER        = { list_name: 'ADD_DRIVER', steps_list: %w[fill_name save_name] }.freeze
# ADD_MANAGER       = { list_name: 'ADD_MANAGER', steps_list: %w[fill_name choose_manager_role save_name] }.freeze
# DRIVERS_LIST      = { list_name: 'DRIVERS_LIST', steps_list: %w[show_drivers in_driver operation_in_driver] }.freeze
# MANAGERS_LIST     = { list_name: 'MANAGERS_LIST',
#                       steps_list: %w[show_managers in_manager operation_in_manager] }.freeze
# ADD_FUEL          = { list_name: 'ADD_FUEL', steps_list: %w[fill_capacity fill_price save_data].freeze }.freeze
# REPAIR_REQUEST    = { list_name: 'REPAIR_REQUEST', steps_list: %w[fill_name save_name] }.freeze
# ADD_TRIP          = { list_name: 'ADD_TRIP',
#                       steps_list: %w[list_number shops distance weight pallets save_trip] }.freeze
# TRIPS_LIST        = { list_name: 'TRIPS_LIST', steps_list: %w[trips_list in_trip operation_in_trip] }.freeze

# def start_add_driver
#   first_step ADD_DRIVER
# end

# def start_drivers_list
#   first_step DRIVERS_LIST
# end

# def start_add_manager
#   first_step ADD_MANAGER
# end

# def start_add_fuel
#   first_step ADD_FUEL
# end

# def start_managers_list
#   first_step MANAGERS_LIST
# end

# def start_repair_request
#   first_step REPAIR_REQUEST
# end

# def start_add_trip
#   first_step ADD_TRIP
# end

# def start_trips_list
#   first_step TRIPS_LIST
# end
