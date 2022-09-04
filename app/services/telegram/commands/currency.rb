require 'net/http'
require 'json'

module Telegram
  module Commands
    class Currency
      CASH_URL = 'https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5'.freeze
      BANK_URL = 'https://api.privatbank.ua/p24api/pubinfo?exchange&json&coursid=11'.freeze

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
        steps_controller.next_step
      end

      def show_currency
        { text: prepare_currency, keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def prepare_currency # rubocop:disable Metrics/AbcSize
        return error.blank if currency.blank?

        string = "#{I18n.t('telegram.messages.currency.name')}\n\n"
        string += "#{I18n.t('telegram.messages.currency.cash_currency')}\n"
        string += "💵 $ #{currency.dig(:cash, 'USD', :buy)} | #{currency.dig(:cash, 'USD', :sale)}\n"
        string += "💶 € #{currency.dig(:cash, 'EUR', :buy)} | #{currency.dig(:cash, 'EUR', :sale)}\n"
        string += "\n#{I18n.t('telegram.messages.currency.bank_currency')}\n"
        string += "💵 $ #{currency.dig(:bank, 'USD', :buy)} | #{currency.dig(:bank, 'USD', :sale)}\n"
        string += "💶 € #{currency.dig(:bank, 'EUR', :buy)} | #{currency.dig(:bank, 'EUR', :sale)}\n"

        string
      end

      def currency
        @currency ||= { cash: cash_currency, bank: bank_currency }
      end

      def cash_currency
        hash = {}
        JSON.parse(Net::HTTP.get_response(URI.parse(CASH_URL)).body).each do |json_cash|
          hash[json_cash['ccy']] = { buy: json_cash['buy'].to_f.round(2),
                                     sale: json_cash['sale'].to_f.round(2) }
        end

        hash
      end

      def bank_currency
        hash = {}
        JSON.parse(Net::HTTP.get_response(URI.parse(BANK_URL)).body).each do |json_bank|
          hash[json_bank['ccy']] = { buy: json_bank['buy'].to_f.round(2),
                                     sale: json_bank['sale'].to_f.round(2) }
        end

        hash
      end
    end
  end
end
