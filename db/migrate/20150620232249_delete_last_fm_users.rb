class DeleteLastFmUsers < ActiveRecord::Migration
  def change
    remove_index :users_sessions, name: 'index_users_sessions_on_session_id_and_last_fm_id'
    remove_column :users_sessions, :last_fm_id
    drop_table :last_fm_users
  end
end
