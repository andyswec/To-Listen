class SeparateLastFmAndSpotifyFromUsers < ActiveRecord::Migration
  def change
    drop_table :users_sessions
    drop_table :users

    create_table :spotify_users, id: false do |t|
      t.string :id, null: false, unique: true, primary_key: true
      t.string :rspotify_hash

      t.timestamps null: false
    end

    create_table :last_fm_users, id: false do |t|
      t.string :id, null: false, unique: true, primary_key: true
      t.string :name

      t.timestamps null:false
    end

    create_table :users_sessions, id: false do |t|


      t.references :session, type: :string, null: false, references: :sessions
      t.references :spotify, type: :string, references: :spotify_users
      t.references :last_fm, type: :string, references: :last_fm_users

      t.timestamps null:false
    end

    add_index :users_sessions, [:session_id, :spotify_id, :last_fm_id], unique: true, name:
            'index_users_sessions_on_all_columns'

    add_foreign_key :users_sessions, :spotify_users, column: 'spotify_id'
    add_foreign_key :users_sessions, :last_fm_users, column: 'last_fm_id'
  end
end