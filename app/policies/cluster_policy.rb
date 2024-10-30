class ClusterPolicy < ApplicationPolicy
  attr_reader :notes

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def initialize(user, record, notes = [])
    super(user, record)
    @notes = notes
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

  def add_notes?
    raise_error _and(record_belongs_to_user?, user_owns_notes?)
  end

  def remove_notes?
    raise_error _and(record_belongs_to_user?, user_owns_notes?)
  end

  private

  def user_owns_notes?
    @notes.all? { |note| note.user == user } ? true : __method__
  end
end
