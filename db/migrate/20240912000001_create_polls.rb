class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: 'draft'
      t.references :organizer, null: false, foreign_key: { to_table: :users }
      
      t.timestamps
    end
    
    add_index :polls, :title
    add_index :polls, :status
  end
end 