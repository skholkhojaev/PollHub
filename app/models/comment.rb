class Comment < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :poll
  
  # Validations
  validates :user_id, presence: true
  validates :poll_id, presence: true
  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  
  # Custom validations
  validate :content_format
  
  # Scopes
  scope :by_poll, ->(poll_id) { where(poll_id: poll_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :latest, -> { order(created_at: :desc) }
  
  # Callbacks
  after_create :log_activity
  
  private
  
  def content_format
    return unless content.present?
    
    # Allowed characters: letters, numbers, specific punctuation, spaces, line breaks
    allowed_pattern = /\A[a-zA-Z0-9.,!?:;\-()'" \r\n]+\z/
    unless content.match?(allowed_pattern)
      errors.add(:content, "contains invalid characters. Only letters, numbers, basic punctuation, spaces, and line breaks are allowed")
    end
  end
  
  def log_activity
    Activity.create(
      user_id: self.user_id,
      activity_type: 'comment_created',
      details: "Comment added to poll: #{self.poll.title}"
    )
  end
end 