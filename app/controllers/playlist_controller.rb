class PlaylistController < ApplicationController
  def playlist
    session_id = session[:session_id]
    Session.connection.execute("UPDATE sessions SET playlist_generated = true WHERE id = #{Session.sanitize(session_id)}")
  end
end
