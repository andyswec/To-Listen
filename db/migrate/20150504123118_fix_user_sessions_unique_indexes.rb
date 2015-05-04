class FixUserSessionsUniqueIndexes < ActiveRecord::Migration
  def change
    remove_index :users_sessions, name: 'index_users_sessions_on_all_columns'
    add_index :users_sessions, [:session_id, :spotify_id], unique: true
    add_index :users_sessions, [:session_id, :last_fm_id], unique: true
  end
end
