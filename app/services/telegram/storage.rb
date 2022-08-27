# frozen_string_literal: true

module Telegram
  class Storage
    attr_reader :store, :bot_start_time

    def initialize
      @bot_start_time = Time.now
    end

    def store_value(telegram_id:, value:)
      return store[telegram_id].merge! value if store.present? && store[telegram_id].present?

      @store = { telegram_id => value }
    end
  end
end
