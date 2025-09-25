class UserPolicy < ApplicationPolicy
  # User management overview - only admins can see all users
  def index?
    user&.admin?
  end

  # Show individual user - users can see their own profile, admins can see all
  def show?
    user == record || user&.admin?
  end

  # Create new users - only through registration (handled separately)
  def create?
    false
  end

  # Edit user details - users can edit their own profile, admins can edit any user
  def edit?
    user == record || user&.admin?
  end

  # Update user details - users can update their own profile, admins can update any user
  def update?
    user == record || user&.admin?
  end

  # Delete users - only admins can delete, but not themselves
  def destroy?
    user&.admin? && user != record
  end

  # Admin-specific methods
  def admin_dashboard?
    user&.admin?
  end

  def admin_user_management?
    user&.admin?
  end

  def edit_user_details?
    user&.admin?
  end

  def assign_roles?
    user&.admin?
  end

  # Scope for user listings
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        # Admins can see all users
        scope.all
      elsif user
        # Regular users can only see their own profile
        scope.where(id: user.id)
      else
        # Unauthenticated users see nothing
        scope.none
      end
    end
  end

  # Permitted attributes for strong parameters
  def permitted_attributes
    if user&.admin?
      # Admins can edit all user attributes
      [:username, :email, :role_integer, :password]
    elsif user == record
      # Users can only edit their own basic info (not role)
      [:username, :email, :password]
    else
      []
    end
  end

  def permitted_attributes_for_admin_update
    [:username, :email, :role_integer, :password]
  end

  def permitted_attributes_for_profile_update
    [:username, :email, :password]
  end
end
