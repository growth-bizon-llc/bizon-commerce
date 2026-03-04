class StorePolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    user.owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
