module Telegram
  module Commands
    class Weather
      TOKEN = ENV.fetch('WEATHER_TOKEN') || Figaro.env.weather_token

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

      def show_weather
        { text: prepare_weather, keyboard: keyboard.home_keyboard(current_user.role) }
      end

      def prepare_weather
        string = "📍 #{data.name} #{to_celsius data.main.temp}°C\n#{description}\n"
        string += sunset_and_sunrise + humidity_and_wind

        string
      end

      def client
        @client ||= OpenWeather::Client.new(api_key: TOKEN)
      end

      def data
        @data ||= client.current_weather(city: 'Lviv', lang: current_user.config.locale)
      end

      def description
        data.weather.first.description.capitalize
      end

      def min_and_max_temp
        "🌡️ #{to_celsius data.main.temp_min}°C - #{to_celsius data.main.temp_max}°C\n"
      end

      def sunset_and_sunrise
        "🌅 #{data.sys.sunrise.strftime('%H:%M')}, 🌇 #{data.sys.sunset.strftime('%H:%M')}\n"
      end

      def humidity_and_wind
        "💧 #{data.main.humidity}% 💨 #{data.wind.speed.round(1)} m/s\n"
      end

      def to_celsius(kelvin)
        (kelvin - 273.15).round 1
      end
    end
  end
end
