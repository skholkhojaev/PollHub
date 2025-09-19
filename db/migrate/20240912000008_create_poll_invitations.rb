class CreatePollInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_invitations do |t|
      t.references :poll, null: false, foreign_key: true
      t.references :voter, null: false, foreign_key: { to_table: :users }
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'pending'
      
      t.timestamps
    end
    
    add_index :poll_invitations, [:poll_id, :voter_id], unique: true
    add_index :poll_invitations, :status
  end
end 