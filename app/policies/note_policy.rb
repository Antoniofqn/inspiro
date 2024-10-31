class NotePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def index?
    true
  end

  def show?
    raise_error _and(record_belongs_to_user?)
  end

  def create?
    raise_error _and(user_can_create_over_note_limit?)
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  def associate_tags?
    raise_error _and(records_belongs_to_user?)
  end

  private

  def user_can_create_over_note_limit?
    user.premium? || user.notes.size <= FREE_NOTE_LIMIT ? true : __method__
  end
end
