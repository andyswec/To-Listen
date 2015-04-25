class SetGeneratedPlaylistDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :sessions, :generated_playlist, false
  end
end
