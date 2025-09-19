class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :user, foreign_key: true
      t.string :activity_type, null: false
      t.text :details, null: false
      
      t.timestamps
    end
    
    add_index :activities, :activity_type
  end
end 