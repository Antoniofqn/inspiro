# app/services/ai/base_ai_service.rb
module Ai
  class BaseAiService
    attr_reader :client

    def initialize
      @client = OpenAI::Client.new(access_token: ENV['GPT_SECRET_KEY'])
    end

    # Method to perform an AI request; expects child classes to provide `build_prompt`
    def fetch_response
      retries = 0
      begin
        sleep(20 * retries) if retries > 0  # Add delay based on retries
        response = @client.chat(
          parameters: {
            model: "gpt-4",  # or "gpt-4" for the GPT-4 model
            messages: [{ role: "user", content: build_prompt }],
            max_tokens: response_length,
            temperature: temperature
          }
        )
        binding.pry
        handle_response(response)
      rescue Faraday::TooManyRequestsError => e
        retries += 1
        retry if retries < 3
        Rails.logger.error "Request limit exceeded: #{e.message}"
        []
      end
    end

    private

    # These methods are intended to be overridden by child services as needed
    def build_prompt
      raise NotImplementedError, "Child classes must implement the build_prompt method"
    end

    def response_length
      50 # default max tokens, can be overridden in child class
    end

    def temperature
      0.5 # default temperature, can be overridden in child class
    end

    # Handle AI response parsing
    def handle_response(response)
      binding.pry
      response['choices'][0]['text'].strip.split(", ").map(&:downcase)
    end
  end
end
