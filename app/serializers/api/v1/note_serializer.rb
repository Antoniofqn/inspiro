# frozen_string_literal: true

module Api
  module V1
    class NoteSerializer < Api::ApiSerializer

      set_id :hashid

      attributes :title, :content, :summary

      attribute :tags do |object|
        object.tags.map do |tag|
          {
            id: tag.hashid,
            name: tag.name
          }
        end
      end
    end
  end
end
