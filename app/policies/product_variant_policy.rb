class ProductVariantPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    user.admin? || user.owner?
  end
end
