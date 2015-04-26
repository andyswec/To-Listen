require 'json'

class SpotifyController < ApplicationController
  def login
    position = params[:position]
    state = !position.nil? ? {'position' => position} : nil

    url = URI.parse 'https://accounts.spotify.com/authorize'
    params = {client_id: CLIENT_ID, response_type: 'code', redirect_uri: REDIRECT_URI, show_dialog: true} #TODO supply scope
    params[:state] = state unless (state.nil?)

    url.query = URI.encode_www_form(params)
    redirect_to url.to_s
  end

  def callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])

    state = params[:state]
    position = state.nil? ? nil : eval(state)['position'].to_i

    user = SpotifyUser.new(id: spotify_user.id, rspotify_hash: JSON.generate(spotify_user.to_hash))
    user.save

    current_session = Session.new(id: session[:session_id])
    current_session.save

    if position.nil?
      user_session = UserSession.new(session_id: session[:session_id], spotify_user: user)
      user_session.save
    else
      user_session = UserSession.where(session_id: session[:session_id]).order(:created_at)[position - 1]
      user_session.spotify_user = user
      user_session.save
    end

    redirect_to root_path
  end
end