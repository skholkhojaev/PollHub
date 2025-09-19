class Option < ActiveRecord::Base
  # Associations
  belongs_to :question
  has_many :votes, dependent: :destroy
  
  # Validations
  validates :question_id, presence: true
  validates :text, presence: true, length: { minimum: 1, maximum: 255 }
  
  # Custom validations
  validate :text_format
  
  # Custom methods
  def vote_count
    self.votes.count
  end
  
  def vote_percentage(total_votes)
    return 0 if total_votes.zero?
    ((self.votes.count.to_f / total_votes) * 100).round(1)
  end
  
  private
  
  def text_format
    return unless text.present?
    
    # Allowed characters: letters, numbers, specific punctuation, spaces
    allowed_pattern = /\A[a-zA-Z0-9.,!?:;\-()'" ]+\z/
    unless text.match?(allowed_pattern)
      errors.add(:text, "contains invalid characters. Only letters, numbers, basic punctuation, and spaces are allowed")
    end
  end
end 