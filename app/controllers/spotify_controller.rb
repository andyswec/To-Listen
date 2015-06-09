
class SpotifyController < ApplicationController
  def login
    position = params[:id] # TODO change id to position as it is a position in fact
    state = !position.nil? ? {'position' => position} : nil

    url = URI.parse 'https://accounts.spotify.com/authorize'
    params = {client_id: SPOTIFY_CLIENT_ID, response_type: 'code', redirect_uri: SPOTIFY_REDIRECT_URI, show_dialog: true, scope:
        'user-library-read playlist-read-private playlist-modify-public playlist-modify-private'}
    params[:state] = state unless (state.nil?)

    url.query = URI.encode_www_form(params)
    redirect_to url.to_s
  end

  def callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

    state = params[:state]
    position = state.nil? ? nil : eval(state)['position'].to_i

    user = SpotifyUser.find_by(id: spotify_user.id) || SpotifyUser.new(id: spotify_user.id)
    user.rspotify_hash = spotify_user.to_hash
    user.save

    current_session = Session.new(id: session[:session_id])
    current_session.save

    if position.nil?
      user_session = UserSession.new(session_id: session[:session_id], spotify_user: user)
    else
      user_session = UserSession.where(session_id: session[:session_id]).order(:created_at)[position]
      user_session.spotify_user = user
    end

    if !user_session.save
      failure 'Failed to add user. User already added.'
      return
    end

    redirect_to root_path
  end

  def failure(message = nil)
    flash[:alert] = message || 'Failed to add user.'
    redirect_to root_path
  end
end