class ChangeUserRoleToEnum < ActiveRecord::Migration[5.2]
  def up
    # Add a new integer column for enum
    add_column :users, :role_integer, :integer, default: 0, null: false
    
    # Update existing data: map string roles to enum values
    execute <<-SQL
      UPDATE users SET role_integer = CASE 
        WHEN role = 'voter' THEN 0
        WHEN role = 'organizer' THEN 1  
        WHEN role = 'admin' THEN 2
        ELSE 0
      END
    SQL
    
    # Add index for performance
    add_index :users, :role_integer
  end
  
  def down
    remove_column :users, :role_integer
  end
end
