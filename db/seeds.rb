# Create admin user
admin = User.create!(
  username: 'admin',
  email: 'admin@example.com',
  password: 'AdminPassword123!',
  role: 'admin'
)

# Create organizer user
organizer = User.create!(
  username: 'organizer',
  email: 'organizer@example.com',
  password: 'OrganizerPass123!',
  role: 'organizer'
)

# Create voter users
voter1 = User.create!(
  username: 'voter1',
  email: 'voter1@example.com',
  password: 'VoterPassword123!',
  role: 'voter'
)

voter2 = User.create!(
  username: 'voter2',
  email: 'voter2@example.com',
  password: 'VoterPassword123!',
  role: 'voter'
)

# Create a sample poll
poll = Poll.create!(
  title: 'Favorite Programming Language',
  description: 'Which programming language do you prefer for backend development?',
  start_date: Date.today,
  end_date: Date.today + 7.days,
  status: 'active',
  organizer_id: organizer.id
)

# Create questions
question1 = Question.create!(
  poll_id: poll.id,
  text: 'What is your primary programming language?',
  question_type: 'single_choice'
)

question2 = Question.create!(
  poll_id: poll.id,
  text: 'Which frameworks have you used? (Select all that apply)',
  question_type: 'multiple_choice'
)

# Create options for question 1
option1_1 = Option.create!(question_id: question1.id, text: 'Ruby')
option1_2 = Option.create!(question_id: question1.id, text: 'Python')
option1_3 = Option.create!(question_id: question1.id, text: 'JavaScript')
option1_4 = Option.create!(question_id: question1.id, text: 'Java')
option1_5 = Option.create!(question_id: question1.id, text: 'C Sharp')

# Create options for question 2
option2_1 = Option.create!(question_id: question2.id, text: 'Ruby on Rails')
option2_2 = Option.create!(question_id: question2.id, text: 'Django')
option2_3 = Option.create!(question_id: question2.id, text: 'ExpressJS')
option2_4 = Option.create!(question_id: question2.id, text: 'Spring Boot')
option2_5 = Option.create!(question_id: question2.id, text: 'ASP NET Core')

# Create some sample votes
Vote.create!(user_id: voter1.id, question_id: question1.id, option_id: option1_1.id)
Vote.create!(user_id: voter2.id, question_id: question1.id, option_id: option1_3.id)

Vote.create!(user_id: voter1.id, question_id: question2.id, option_id: option2_1.id)
Vote.create!(user_id: voter1.id, question_id: question2.id, option_id: option2_3.id)
Vote.create!(user_id: voter2.id, question_id: question2.id, option_id: option2_3.id)

puts "Database seeded successfully!" 