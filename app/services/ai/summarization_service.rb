module Ai
  class SummarizationService < BaseAiService
    def initialize(content)
      super()
      @content = content
    end

    def summarize
      response = fetch_response
      JSON.parse(response)['content']
    rescue StandardError => e
      Rails.logger.error "Summarization failed: #{e.message}"
      ""
    end

    private

    def build_prompt
      "Summarize the following text:\n\n\"#{@content}\"\n\nRespond in the following JSON format:\n\n{ \"content\": \"your summary here\" }"
    end

    def response_length
      100
    end
  end
end
