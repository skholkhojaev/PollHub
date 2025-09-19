class PollInvitation < ActiveRecord::Base
  # Associations
  belongs_to :poll
  belongs_to :voter, class_name: 'User'
  belongs_to :invited_by, class_name: 'User'
  
  # Validations
  validates :poll_id, presence: true
  validates :voter_id, presence: true
  validates :invited_by_id, presence: true
  validates :status, presence: true, inclusion: { in: ['pending', 'accepted', 'declined'] }
  validates :poll_id, uniqueness: { scope: :voter_id, message: "Voter already invited to this poll" }
  
  # Ensure only voters can be invited
  validate :voter_must_be_voter_role
  
  # Ensure only organizers or admins can invite
  validate :inviter_must_have_permission
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :declined, -> { where(status: 'declined') }
  scope :for_poll, ->(poll_id) { where(poll_id: poll_id) }
  scope :for_voter, ->(voter_id) { where(voter_id: voter_id) }
  
  # Instance methods
  def accept!
    update(status: 'accepted')
  end
  
  def decline!
    update(status: 'declined')
  end
  
  def pending?
    status == 'pending'
  end
  
  def accepted?
    status == 'accepted'
  end
  
  def declined?
    status == 'declined'
  end
  
  private
  
  def voter_must_be_voter_role
    return unless voter
    
    unless voter.role == 'voter'
      errors.add(:voter, "Only users with voter role can be invited")
    end
  end
  
  def inviter_must_have_permission
    return unless invited_by && poll
    
    unless ['admin', 'organizer'].include?(invited_by.role) || invited_by.id == poll.organizer_id
      errors.add(:invited_by, "Only organizers and admins can invite voters")
    end
  end
end 