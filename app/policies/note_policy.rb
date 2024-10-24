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
    true
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
