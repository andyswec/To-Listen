class AddLastFmUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_fm_username, :string
    add_index :users, :last_fm_username
    add_index :users, [:spotify_id, :last_fm_username], unique: true
  end
end
