class Poll < ActiveRecord::Base
  # Associations
  belongs_to :organizer, class_name: 'User'
  has_many :questions, dependent: :destroy
  has_many :votes, through: :questions
  has_many :comments, dependent: :destroy
  has_many :poll_invitations, dependent: :destroy
  has_many :invited_voters, through: :poll_invitations, source: :voter
  
  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :status, presence: true, inclusion: { in: ['draft', 'active', 'closed'] }
  validates :start_date, presence: true
  validates :end_date, presence: true
  
  # Custom validations
  validate :title_format
  validate :description_format
  validate :start_date_validation
  validate :end_date_validation
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :draft, -> { where(status: 'draft') }
  scope :closed, -> { where(status: 'closed') }
  scope :by_organizer, ->(user_id) { where(organizer_id: user_id) }
  scope :public_polls, -> { where(private: false) }
  scope :private_polls, -> { where(private: true) }
  
  # Callbacks
  before_save :log_activity
  
  # Custom methods
  def active?
    self.status == 'active'
  end
  
  def closed?
    self.status == 'closed'
  end
  
  def private?
    self.private == true
  end
  
  def public?
    !private?
  end
  
  def total_votes
    self.votes.count
  end
  
  def close_poll
    self.update(status: 'closed')
  end
  
  # Check if a user has access to this poll
  def user_has_access?(user)
    return true if public?
    return true if user.nil? == false && (['admin', 'organizer'].include?(user.role) || organizer_id == user.id)
    return false unless user && user.role == 'voter'
    
    # Check if voter has been invited and accepted
    poll_invitations.accepted.where(voter_id: user.id).exists?
  end
  
  # Invite a voter to this private poll
  def invite_voter(voter, invited_by)
    return false unless private?
    return false unless voter.role == 'voter'
    return false unless ['admin', 'organizer'].include?(invited_by.role) || invited_by.id == organizer_id
    
    poll_invitations.create(
      voter: voter,
      invited_by: invited_by,
      status: 'pending'
    )
  end
  
  private
  
  def title_format
    return unless title.present?
    
    # Allowed characters: letters, numbers, specific punctuation, spaces
    allowed_pattern = /\A[a-zA-Z0-9.,!?:;\-()'" ]+\z/
    unless title.match?(allowed_pattern)
      errors.add(:title, "contains invalid characters. Only letters, numbers, basic punctuation, and spaces are allowed")
    end
  end
  
  def description_format
    return unless description.present?
    
    # Allowed characters: letters, numbers, specific punctuation, spaces, line breaks
    allowed_pattern = /\A[a-zA-Z0-9.,!?:;\-()'" \r\n]+\z/
    unless description.match?(allowed_pattern)
      errors.add(:description, "contains invalid characters. Only letters, numbers, basic punctuation, spaces, and line breaks are allowed")
    end
  end
  
  def start_date_validation
    return unless start_date.present?
    
    # Not more than 1 year in the future
    if start_date > Date.current + 1.year
      errors.add(:start_date, "cannot be more than 1 year in the future")
    end
  end
  
  def end_date_validation
    return unless end_date.present? && start_date.present?
    
    # Must be after start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
      return
    end
    
    # Not more than 1 year after start_date
    if end_date > start_date + 1.year
      errors.add(:end_date, "cannot be more than 1 year after the start date")
    end
  end
  
  def log_activity
    return unless self.changed?
    
    if self.new_record?
      activity_type = 'poll_created'
    else
      activity_type = 'poll_updated'
    end
    
    Activity.create(
      user_id: self.organizer_id,
      activity_type: activity_type,
      details: "Poll #{self.title} #{self.new_record? ? 'created' : 'updated'}"
    )
  end
end 