class Activity < ActiveRecord::Base
  # Associations
  belongs_to :user, optional: true
  
  # Validations
  validates :activity_type, presence: true
  validates :details, presence: true
  
  # Scopes
  scope :by_type, ->(type) { where(activity_type: type) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :latest, -> { order(created_at: :desc) }
  
  # Constants
  ACTIVITY_TYPES = [
    'user_created',
    'user_updated',
    'poll_created',
    'poll_updated',
    'vote_cast',
    'comment_created',
    'login',
    'logout'
  ]
end 