class AdminPolicy < ApplicationPolicy
  # Admin dashboard access
  def dashboard?
    user&.admin?
  end

  # User management access
  def user_management?
    user&.admin?
  end

  # System administration
  def system_administration?
    user&.admin?
  end

  # Activity monitoring
  def activity_monitoring?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
