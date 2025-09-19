class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :poll, null: false, foreign_key: true
      t.text :content, null: false
      
      t.timestamps
    end
    
    add_index :comments, [:user_id, :poll_id, :created_at]
  end
end 