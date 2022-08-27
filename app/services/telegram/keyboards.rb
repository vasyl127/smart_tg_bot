# frozen_string_literal: true

module Telegram
  class Keyboards
    attr_reader :primary_keys, :secondary_keys

    def initialize
      @primary_keys   = primary_keys_list
      @secondary_keys = secondary_keys_list
    end

    def primary_keys_list # rubocop:disable Metrics/MethodLength
      { home: locale('home'),
        language: locale('language'),
        add_driver: locale('add_driver'),
        add_manager: locale('add_manager'),
        drivers_list: locale('drivers_list'),
        managers_list: locale('managers_list'),
        add_trip: locale('add_trip'),
        trips_list: locale('trips_list'),
        add_fuel: locale('add_fuel'),
        notifications: locale('notification'),
        repair_request: locale('repair_request') }
    end

    def secondary_keys_list
      { delete: locale('delete'),
        delete_all: locale('delete_all'),
        language_ua: locale('language_ua'),
        language_en: locale('language_en'),
        fuel: locale('fuel'),
        repair_requests: locale('repair_requests'),
        repair_manager: locale('repair_manager'),
        trip_manager: locale('trip_manager'),
        back: locale('back') }
    end

    def home_roles_keyboard(role) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      kb = case role
           when 'admin'
             [[primary_keys[:drivers_list], primary_keys[:managers_list]],
              primary_keys[:notifications], primary_keys[:language]]
           when 'trip_manager'
             [primary_keys[:drivers_list], primary_keys[:notifications], primary_keys[:language]]
           when 'repair_manager'
             [primary_keys[:drivers_list], primary_keys[:notifications], primary_keys[:language]]
           when 'driver'
             [[primary_keys[:trips_list], primary_keys[:repair_request]], primary_keys[:language]]
           end

      generate_bottom_buttons kb
    end

    def notifications_list
      kb = [secondary_keys[:delete_all], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_manager_keyboard
      kb = [secondary_keys[:delete], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_driver_for_trip_manager
      kb = [primary_keys[:trips_list], secondary_keys[:delete], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_driver_for_repair_manager
      kb = [secondary_keys[:repair_requests], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_driver_for_admin
      kb = [secondary_keys[:repair_requests], primary_keys[:trips_list],
            secondary_keys[:delete], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_fuel
      kb = [primary_keys[:add_fuel], secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_fuel_or_request
      kb = [secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def drivers_list(drivers)
      kb = [primary_keys[:add_driver]]
      drivers.each { |driver| kb << driver } if drivers.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def managers_list(managers)
      kb = [primary_keys[:add_manager]]
      managers.each { |manager| kb << manager } if managers.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def trips_list(trips)
      kb = [primary_keys[:add_trip]]
      trips.each { |trip| kb << trip.list_number } if trips.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_trip
      kb = [secondary_keys[:fuel],
            secondary_keys[:delete], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def language_keyboard
      kb = [[secondary_keys[:language_ua], secondary_keys[:language_en]], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def choose_manager_role
      kb = [[secondary_keys[:repair_manager], secondary_keys[:trip_manager]], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    private

    def locale(value)
      I18n.t("telegram.buttons.#{value}")
    end

    def generate_inline_buttons(buttons)
      kb = []
      buttons.each do |button|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: button, callback_data: 'button')
      end

      Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
    end

    def generate_bottom_buttons(buttons)
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons, one_time_keyboard: true, resize_keyboard: true)
    end
  end
end
