# frozen_string_literal: true

module Telegram
  class Errors
    attr_reader :errors

    def initialize
      @errors = []
    end

    def any?
      errors.present?
    end

    def none?
      errors.empty?
    end

    def add_errors(message)
      errors << message
    end

    def blank
      add_errors I18n.t('telegram.errors.blank')
    end

    def all_messages
      string = "#{I18n.t('telegram.errors.error')}:\n\n"
      errors.flatten.map { |error| string += "- #{error} \n" }.to_s

      string
    end

    def incorect_fuel_capacity
      add_errors(I18n.t('telegram.errors.incorect_fuel_capacity'))
    end

    def incorect_fuel_price
      add_errors(I18n.t('telegram.errors.incorect_fuel_price'))
    end

    def not_permission
      add_errors(I18n.t('telegram.errors.not_permission'))
    end
  end
end
