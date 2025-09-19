class Vote < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :option
  belongs_to :question
  
  # Validations
  validates :option_id, presence: true
  validates :question_id, presence: true
  
  # Make sure a user can only vote once per question for single choice questions
  validate :one_vote_per_question_for_single_choice
  
  # Callbacks
  after_create :log_activity
  
  private
  
  def one_vote_per_question_for_single_choice
    if question && question.single_choice?
      existing_vote = Vote.where(user_id: user_id, question_id: question_id).where.not(id: id).exists?
      if existing_vote
        errors.add(:base, "You have already voted on this question")
      end
    end
  end
  
  def log_activity
    Activity.create(
      user_id: self.user_id,
      activity_type: 'vote_cast',
      details: "Vote cast for poll: #{self.question.poll.title}, question: #{self.question.text}"
    )
  end
end 