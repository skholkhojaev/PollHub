class AddPrivateToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :private, :boolean, default: false
  end
end 