class OrderPolicy < ApplicationPolicy
  def update?
    user.admin? || user.owner?
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
