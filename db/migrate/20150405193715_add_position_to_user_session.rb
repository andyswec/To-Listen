class AddPositionToUserSession < ActiveRecord::Migration
  def change
    add_column :users_sessions, :position, :integer, null: false
    add_index :users_sessions, :position
    add_index :users_sessions, [:session_id, :position], unique: true
  end
end
