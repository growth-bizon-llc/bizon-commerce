class CategoryPolicy < ApplicationPolicy
  def create?
    user.admin? || user.owner?
  end

  def update?
    user.admin? || user.owner?
  end

  def destroy?
    user.admin? || user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
