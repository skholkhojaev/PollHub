class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      
      t.timestamps
    end
    
    # A user can only vote once per option
    add_index :votes, [:user_id, :option_id], unique: true
  end
end 