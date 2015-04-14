class PlaylistController < ApplicationController
  def playlist
    session_id = session[:session_id]
    session = Session.find(session_id)
    session.playlist_generated = true
    session.save
  end
end
