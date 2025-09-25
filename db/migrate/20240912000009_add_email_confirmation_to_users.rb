class AddEmailConfirmationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :new_email, :string
    add_column :users, :email_confirmation_token, :string
    add_column :users, :email_confirmation_sent_at, :datetime
    
    add_index :users, :email_confirmation_token, unique: true
  end
end
