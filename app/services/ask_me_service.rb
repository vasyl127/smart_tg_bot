class AskMeService
  TOKEN = ENV.fetch('OPENAI_TOKEN') || Figaro.env.openai_token

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def generate_answer
    response.dig('choices', 0, 'message', 'content')
  end

  private

  def response
    client.chat(parameters: { model: 'gpt-3.5-turbo',
                              messages: [{ role: 'user', content: message}],
                              temperature: 0.7 })
  end

  def client
    @client ||= OpenAI::Client.new(access_token: TOKEN)
  end
end
