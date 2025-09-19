#!/usr/bin/env ruby

require 'fileutils'
require 'date'
require 'json'

class RepoRecreator
  def initialize(source_path, target_path)
    @source_path = source_path
    @target_path = target_path
    @commit_sequence = build_commit_sequence
    @start_date = Date.new(2024, 7, 15) # Starting date for realistic timeline
  end

  def create_repo_with_history
    puts "🚀 Creating new repository with realistic development history..."
    
    setup_target_repo
    create_realistic_commits
    
    puts "✅ Repository recreation complete!"
    puts "📁 New repository location: #{@target_path}"
    puts "📊 Total commits created: #{@commit_sequence.length}"
  end

  private

  def setup_target_repo
    # Remove target if exists
    FileUtils.rm_rf(@target_path) if Dir.exist?(@target_path)
    
    # Create new directory and initialize git
    FileUtils.mkdir_p(@target_path)
    Dir.chdir(@target_path) do
      system("git init")
      system("git config user.name 'Developer'")
      system("git config user.email 'developer@example.com'")
    end
  end

  def create_realistic_commits
    current_date = @start_date
    
    @commit_sequence.each_with_index do |commit_info, index|
      puts "📝 Creating commit #{index + 1}/#{@commit_sequence.length}: #{commit_info[:message]}"
      
      # Copy files for this commit
      copy_files_for_commit(commit_info[:files])
      
      # Stage and commit
      Dir.chdir(@target_path) do
        commit_info[:files].each do |file|
          system("git add #{file}")
        end
        
        # Calculate realistic timestamp
        timestamp = calculate_commit_timestamp(current_date, index)
        
        # Create commit with backdated timestamp
        commit_cmd = "GIT_AUTHOR_DATE='#{timestamp}' GIT_COMMITTER_DATE='#{timestamp}' git commit -m '#{commit_info[:message]}'"
        system(commit_cmd)
      end
      
      # Advance date realistically
      current_date = advance_date(current_date, index)
    end
  end

  def copy_files_for_commit(files)
    files.each do |file|
      source_file = File.join(@source_path, file)
      target_file = File.join(@target_path, file)
      
      if File.exist?(source_file)
        FileUtils.mkdir_p(File.dirname(target_file))
        FileUtils.cp(source_file, target_file)
      end
    end
  end

  def calculate_commit_timestamp(base_date, commit_index)
    # Add realistic working hours and some randomness
    days_offset = commit_index * rand(1..3) # 1-3 days between commits
    hour = 9 + rand(9) # Work hours 9 AM - 6 PM
    minute = rand(60)
    
    timestamp = base_date + days_offset
    "#{timestamp.strftime('%Y-%m-%d')} #{hour.to_s.rjust(2, '0')}:#{minute.to_s.rjust(2, '0')}:00"
  end

  def advance_date(current_date, commit_index)
    # Skip weekends occasionally, add realistic development pace
    days_to_add = case commit_index % 10
                  when 0..2 then 1 # Daily commits for initial push
                  when 3..6 then 2 # Every other day for steady development  
                  when 7..8 then 3 # Slower pace later
                  else 5 # Occasional gaps
                  end
    
    new_date = current_date + days_to_add
    
    # Skip weekends (make it look like weekday development)
    while [0, 6].include?(new_date.wday)
      new_date += 1
    end
    
    new_date
  end

  def build_commit_sequence
    [
      # Phase 1: Project Foundation
      {
        message: "Initial commit: Set up Sinatra application structure",
        files: %w[Gemfile README.md config.ru app.rb .gitignore]
      },
      {
        message: "Add database configuration and ActiveRecord setup",  
        files: %w[config/database.yml config/environments.rb Rakefile]
      },
      {
        message: "Create basic application layout and routing",
        files: %w[app/views/layout.slim app/views/index.slim public/css/style.css]
      },
      {
        message: "Configure development environment and dependencies",
        files: %w[Gemfile.lock config/environments.rb]
      },
      {
        message: "Set up Rack configuration and middleware",
        files: %w[config.ru]
      },

      # Phase 2: User Authentication  
      {
        message: "Create User model and authentication foundation",
        files: %w[db/migrate/20240912000000_create_users.rb app/models/user.rb]
      },
      {
        message: "Implement login and registration routes",
        files: %w[app.rb app/views/login.slim app/views/register.slim]
      },
      {
        message: "Add BCrypt for secure password handling",
        files: %w[Gemfile app/models/user.rb]
      },
      {
        message: "Implement session management and authentication helpers",
        files: %w[app.rb]
      },
      {
        message: "Create authentication views and user forms",
        files: %w[app/views/login.slim app/views/register.slim]
      },
      {
        message: "Add comprehensive user validation and security",
        files: %w[app/models/user.rb]
      },

      # Phase 3: Core Polling System
      {
        message: "Create Poll model and basic structure",
        files: %w[db/migrate/20240912000001_create_polls.rb app/models/poll.rb]
      },
      {
        message: "Add Question model with poll relationships",
        files: %w[db/migrate/20240912000002_create_questions.rb app/models/question.rb]
      },
      {
        message: "Implement Option model for question choices",
        files: %w[db/migrate/20240912000003_create_options.rb app/models/option.rb]
      },
      {
        message: "Create Vote model for recording user votes",
        files: %w[db/migrate/20240912000004_create_votes.rb app/models/vote.rb]
      },
      {
        message: "Implement poll controller with CRUD operations",
        files: %w[app/controllers/polls_controller.rb]
      },
      {
        message: "Add question management functionality",
        files: %w[app/controllers/questions_controller.rb app/views/questions/new.slim]
      },
      {
        message: "Create option management for questions",
        files: %w[app/controllers/options_controller.rb app/views/options/new.slim]
      },
      {
        message: "Implement voting system and vote recording",
        files: %w[app/controllers/votes_controller.rb]
      },

      # Phase 4: UI and User Experience
      {
        message: "Enhance layout with Bootstrap and navigation",
        files: %w[app/views/layout.slim public/css/style.css]
      },
      {
        message: "Create poll views and user interface",
        files: %w[app/views/polls/show.slim app/views/polls/index.slim app/views/polls/new.slim]
      },
      {
        message: "Improve form handling and error messages",
        files: %w[app/views/polls/edit.slim app.rb]
      },
      {
        message: "Add results visualization and vote display",
        files: %w[app/views/polls/results.slim public/css/style.css]
      },
      {
        message: "Implement responsive design and basic styling",
        files: %w[public/css/style.css public/js/darkmode.js]
      },

      # Phase 5: Role-Based Access Control
      {
        message: "Add role system to user model",
        files: %w[app/models/user.rb db/seeds.rb]
      },
      {
        message: "Implement authorization helpers and middleware",
        files: %w[app.rb]
      },
      {
        message: "Add access control to poll operations",
        files: %w[app/controllers/polls_controller.rb]
      },
      {
        message: "Create admin controller foundation",
        files: %w[app/controllers/admin_controller.rb]
      },

      # Phase 6: Advanced Features
      {
        message: "Add private poll functionality",
        files: %w[db/migrate/20240912000007_add_private_to_polls.rb app/models/poll.rb]
      },
      {
        message: "Implement poll invitation system",
        files: %w[db/migrate/20240912000008_create_poll_invitations.rb app/models/poll_invitation.rb]
      },
      {
        message: "Add commenting system for polls",
        files: %w[db/migrate/20240912000006_create_comments.rb app/models/comment.rb app/controllers/comments_controller.rb]
      },
      {
        message: "Create activity logging foundation",
        files: %w[db/migrate/20240912000005_create_activities.rb app/models/activity.rb]
      },

      # Phase 7: Infrastructure & Monitoring
      {
        message: "Implement comprehensive logging system",
        files: %w[config/logger.rb lib/logging_utils.rb logs/.gitkeep]
      },
      {
        message: "Add security event tracking and audit trails",
        files: %w[lib/logging_utils.rb app.rb]
      },
      {
        message: "Complete admin dashboard and user management",
        files: %w[app/views/admin/dashboard.slim app/views/admin/users.slim app/views/admin/edit_user.slim]
      },
      {
        message: "Enhance error handling and exception management",
        files: %w[app.rb]
      },

      # Phase 8: Polish & Production
      {
        message: "Add advanced UI features and dark mode support",
        files: %w[public/css/style.css public/js/darkmode.js]
      },
      {
        message: "Optimize database queries and add indexes",
        files: %w[db/migrate/20240912000000_create_users.rb db/migrate/20240912000001_create_polls.rb]
      },
      {
        message: "Update documentation and README",
        files: %w[README.md docs/logging.md]
      },
      {
        message: "Add database seeds and sample data",
        files: %w[db/seeds.rb db/schema.rb]
      }
    ]
  end
end

# Usage
if __FILE__ == $0
  if ARGV.length != 2
    puts "Usage: ruby repo_recreator.rb <source_path> <target_path>"
    puts "Example: ruby repo_recreator.rb /path/to/current/repo /path/to/new/repo"
    exit 1
  end

  source_path = ARGV[0]
  target_path = ARGV[1]

  unless Dir.exist?(source_path)
    puts "❌ Error: Source path '#{source_path}' does not exist"
    exit 1
  end

  recreator = RepoRecreator.new(source_path, target_path)
  recreator.create_repo_with_history
end
