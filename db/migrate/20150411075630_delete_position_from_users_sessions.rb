class DeletePositionFromUsersSessions < ActiveRecord::Migration
  def change
    remove_column :users_sessions, :position
  end
end
