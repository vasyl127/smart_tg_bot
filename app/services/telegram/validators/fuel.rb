# frozen_string_literal: true

module Telegram
  module Validators
    class Fuel
      INTEGER_ONLY = /^\d+$/

      attr_reader :capacity, :price, :errors

      def initialize(fuel_params, errors)
        @errors = errors
        @capacity = fuel_params[:capacity]
        @price = fuel_params[:price]
      end

      def valid?
        validate_capacity && validate_price
      end

      private

      def validate_capacity
        return true if INTEGER_ONLY.match? capacity.to_s

        errors.incorect_fuel_capacity
      end

      def validate_price
        return true if INTEGER_ONLY.match? price.to_s

        errors.incorect_fuel_price
      end
    end
  end
end
