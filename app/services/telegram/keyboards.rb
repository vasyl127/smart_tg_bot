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
        users_list: locale('users_list'),
        add_user: locale('add_user'),
        tasks_list: locale('tasks_list'),
        add_task: locale('add_task'),
        categories_list: locale('categories_list'),
        costs_list: locale('costs_list'),
        add_category: locale('add_category'),
        share_category: locale('share_category'),
        add_cost: locale('add_cost'),
        notifications: locale('notification'),
        weather: locale('weather'),
        random_value: locale('random_value'),
        repair_request: locale('repair_request') }
    end

    def secondary_keys_list
      { delete: locale('delete'),
        delete_all: locale('delete_all'),
        language_ua: locale('language_ua'),
        language_en: locale('language_en'),
        add: locale('add'),
        back: locale('back') }
    end

    def home_keyboard(role) # rubocop:disable Metrics/AbcSize
      kb = []
      kb << [primary_keys[:tasks_list], primary_keys[:random_value]]
      kb << [primary_keys[:categories_list], primary_keys[:weather]]
      kb << primary_keys[:users_list] if role == 'admin'
      kb << [primary_keys[:notifications], primary_keys[:language]]
      kb << primary_keys[:home]

      generate_bottom_buttons kb
    end

    def objects_name_list(objects)
      kb = [primary_keys[:add_task]]
      objects.each { |object| kb << object.name } if objects.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_task
      kb = [secondary_keys[:delete], secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def categories_list(objects)
      kb = [primary_keys[:add_category]]
      objects.each { |object| kb << object.name } if objects.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_category
      kb = [primary_keys[:add_cost], primary_keys[:costs_list], primary_keys[:share_category], secondary_keys[:delete],
            secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def costs_list(objects)
      kb = [primary_keys[:add_cost]]
      objects.each { |object| kb << object.name } if objects.present?
      kb << [secondary_keys[:back]]
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_cost
      kb = [secondary_keys[:delete], secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def users_list(objects)
      kb = [primary_keys[:add_user]]
      objects.each { |object| kb << object.name } if objects.present?
      kb << [primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def in_user
      kb = [secondary_keys[:delete], secondary_keys[:back], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def notifications_list
      kb = [secondary_keys[:delete_all], primary_keys[:home]]

      generate_bottom_buttons kb
    end

    def language_keyboard
      kb = [[secondary_keys[:language_ua], secondary_keys[:language_en]], primary_keys[:home]]

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
