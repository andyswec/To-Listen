class AddPositionToTrackSession < ActiveRecord::Migration
  def change
    add_column :tracks_sessions, :position, :integer

    remove_index :tracks_sessions, name: 'index_tracks_sessions_on_all_columns'
    add_index :tracks_sessions, [:session_id, :track_id, :position], unique: true, name: 'index_tracks_sessions_on_all_columns'
  end
end
