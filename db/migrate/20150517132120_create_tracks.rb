class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :rspotify_hash

      t.timestamps null: false
    end

    create_table :tracks_sessions do |t|
      t.references :session, type: :string, null: false, references: :sessions
      t.references :track, type: :string, null: false, references: :tracks
    end

    add_index :tracks_sessions, [:session_id, :track_id], unique: true, name: 'index_tracks_sessions_on_all_columns'

    add_foreign_key :tracks_sessions, :tracks, column: 'track_id'
    add_foreign_key :tracks_sessions, :sessions, column: 'session_id'
  end
end
