# app/services/ai/tag_suggestion_service.rb
module Ai
  class TagSuggestionService < Ai::BaseAiService
    def initialize(note)
      super()
      @note = note
      @user = note.user
    end

    def suggest_tags
      ai_response = fetch_response
      parsed_response = parse_response(ai_response)
      (parsed_response[:relevant_existing_tags] + parsed_response[:new_suggested_tags]).uniq
    end


    # Build the prompt to include existing tags and note content, with a structured JSON format request
    def build_prompt
      "Given the note content:\n\n\"#{@note.content}\"\n\n" \
      "and these existing tags: #{user_tags_list}, " \
      "please identify any relevant existing tags and suggest additional tags if necessary. " \
      "Keep the number of new suggested tags to a maximun of 3" \
      "Respond in the following JSON format:\n\n" \
      "{ \"relevant_existing_tags\": [\"tag1\", \"tag2\"], \"new_suggested_tags\": [\"tag3\", \"tag4\"] }"
    end

    # Helper to format the user’s tags as a list
    def user_tags_list
      @user.tags.pluck(:name).join(", ")
    end

    # Parse JSON response for relevant existing and new tags
    def parse_response(ai_response)
      JSON.parse(ai_response, symbolize_names: true)
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse AI response: #{e.message}"
      { relevant_existing_tags: [], new_suggested_tags: [] }
    end
  end
end
