module Api
  module V1
    class TagSerializer < Api::ApiSerializer
      set_id :hashid

      attributes :name

      attribute :user_hashid do |object|
        object.user.hashid
      end

      attribute :notes_ids do |object|
        object.notes.map(&:hashid)
      end
    end
  end
end
