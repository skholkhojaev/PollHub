class Question < ActiveRecord::Base
  # Associations
  belongs_to :poll
  has_many :options, dependent: :destroy
  has_many :votes, dependent: :destroy
  
  # Validations
  validates :poll_id, presence: true
  validates :text, presence: true, length: { minimum: 5, maximum: 500 }
  validates :question_type, presence: true, inclusion: { in: ['single_choice', 'multiple_choice'] }
  
  # Custom validations
  validate :text_format
  
  # Scopes
  scope :by_poll, ->(poll_id) { where(poll_id: poll_id) }
  
  # Custom methods
  def single_choice?
    self.question_type == 'single_choice'
  end
  
  def multiple_choice?
    self.question_type == 'multiple_choice'
  end
  
  def results
    results = {}
    self.options.each do |option|
      results[option.text] = option.votes.count
    end
    results
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