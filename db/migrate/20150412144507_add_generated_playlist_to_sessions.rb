class AddGeneratedPlaylistToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :generated_playlist, :boolean, :default => true
  end
end
