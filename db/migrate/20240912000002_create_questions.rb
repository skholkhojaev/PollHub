class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :text, null: false
      t.string :question_type, null: false, default: 'single_choice'
      
      t.timestamps
    end
  end
end 