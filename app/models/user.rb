class User < ActiveRecord::Base
  has_secure_password
  
  # Associations
  has_many :polls, foreign_key: 'organizer_id'
  has_many :votes
  has_many :activities
  has_many :comments
  has_many :poll_invitations, foreign_key: 'voter_id', dependent: :destroy
  has_many :sent_invitations, class_name: 'PollInvitation', foreign_key: 'invited_by_id', dependent: :destroy
  has_many :invited_polls, through: :poll_invitations, source: :poll
  
  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :role, presence: true, inclusion: { in: ['admin', 'organizer', 'voter'] }
  validates :password, length: { minimum: 8, maximum: 72 }, if: :password_required?
  
  # Custom validations
  validate :username_format
  validate :email_format
  validate :password_strength, if: :password_required?
  
  # Scopes
  scope :voters, -> { where(role: 'voter') }
  scope :organizers, -> { where(role: 'organizer') }
  scope :admins, -> { where(role: 'admin') }
  
  # Callbacks
  before_save :log_activity
  
  # Helper methods for poll access
  def accessible_polls
    if role == 'voter'
      # Voters can see public polls and private polls they're invited to (and accepted)
      public_polls = Poll.public_polls
      private_polls_with_access = Poll.joins(:poll_invitations)
                                    .where(poll_invitations: { voter_id: id, status: 'accepted' })
      Poll.where(id: public_polls.pluck(:id) + private_polls_with_access.pluck(:id))
    else
      # Admins and organizers can see all polls
      Poll.all
    end
  end
  
  def pending_invitations
    poll_invitations.pending.includes(:poll, :invited_by)
  end
  
  def can_access_poll?(poll)
    poll.user_has_access?(self)
  end
  
  private
  
  def username_format
    return unless username.present?
    
    # Check for leading/trailing spaces
    if username != username.strip
      errors.add(:username, "cannot have leading or trailing spaces")
      return
    end
    
    # Check allowed characters: letters, numbers, specific special characters
    allowed_pattern = /\A[a-zA-Z0-9!"#$%&'()*+,\-.\/:;<=>?@\[\\\]^_`{|}~]+\z/
    unless username.match?(allowed_pattern)
      errors.add(:username, "contains invalid characters. Only letters, numbers, and specific special characters are allowed")
    end
  end
  
  def email_format
    return unless email.present?
    
    # Basic email format validation
    email_pattern = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
    unless email.match?(email_pattern)
      errors.add(:email, "is not a valid email format")
    end
  end
  
  def password_strength
    return unless password.present?
    
    errors.add(:password, "must contain at least one uppercase letter") unless password.match?(/[A-Z]/)
    errors.add(:password, "must contain at least one lowercase letter") unless password.match?(/[a-z]/)
    errors.add(:password, "must contain at least one number") unless password.match?(/\d/)
    errors.add(:password, "must contain at least one special character") unless password.match?(/[!"#$%&'()*+,\-.\/:;<=>?@\[\\\]^_`{|}~]/)
  end
  
  def password_required?
    new_record? || password.present?
  end
  
  def log_activity
    return unless self.changed?
    
    if self.new_record?
      activity_type = 'user_created'
    else
      activity_type = 'user_updated'
    end
    
    Activity.create(
      user_id: self.id,
      activity_type: activity_type,
      details: "User #{self.username} #{self.new_record? ? 'created' : 'updated'}"
    )
  end
end 