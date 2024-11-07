# app/services/ai/semantic_search_service.rb
module Ai
  class SemanticSearchService < BaseAiService
    def initialize(query, user)
      super()
      @query = query
      @user = user
    end

    def search_notes
      summaries = @user.notes.where.not(summary: nil).pluck(:summary, :id)
      results = fetch_response(summaries)
      results['ids'].map { |id| Note.find(id) }
    end

    private

    def build_prompt(summaries)
      summaries_text = summaries.map { |summary, id| "Note ID #{id}: #{summary}" }.join("\n")
      "Given the search query: #{@query}\n\n" \
      "Find the most relevant notes based on the following summaries:\n#{summaries_text}\n" \
      "Return the IDs of the most relevant notes as a json: { \"ids\": [1, 2, 3] }"
    end

    def fetch_response(summaries)
      prompt = build_prompt(summaries)
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 50,
          temperature: 0.3,
          response_format: {
            type: 'json_object'
          }
        }
      )
      parse_response(response)
    end

    def parse_response(response)
      JSON.parse(response['choices'][0]['message']['content'])
    rescue JSON::ParserError
      Rails.logger.error "Failed to parse AI response for semantic search"
      []
    end
  end
end
