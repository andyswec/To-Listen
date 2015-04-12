class MakeUsersSpotifyIdAndLastFmUsernameUnique < ActiveRecord::Migration
  def up
    remove_index :users, :spotify_id
    add_index :users, :spotify_id, unique: true, where: (:last_fm_username.to_s + " IS NULL")

    remove_index :users, :last_fm_username
    add_index :users, :last_fm_username, unique: true, where: (:spotify_id.to_s + " IS NULL")
  end

  def down
    remove_index :users, :spotify_id
    add_index :users, :spotify_id
    remove_index :users, :last_fm_username
    add_index :users, :last_fm_username
  end
end
