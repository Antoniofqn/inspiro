# frozen_string_literal: true

module Api
  module V1
    class ClusterSerializer < Api::ApiSerializer

      set_id :hashid

      attributes :name

      attribute :notes do |object|
        object.notes.map do |note|
          {
            id: note.hashid,
            title: note.title
          }
        end
      end
    end
  end
end
