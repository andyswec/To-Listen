require 'rspotify'
require 'lastfm'

class PlaylistController < ApplicationController

  def playlist
    session_id = session[:session_id]
    session = Session.find(session_id)

    user_sessions = session.user_sessions

    users = []
    user_sessions.each do |us|
      users << PlaylistHelper::SpotifyLastFmUser.new(user_session: us)
    end

    # Get spotify ids for tracks
    # last_fm_tracks.each do |t|
    #   query = 'artist:"' + t['artist']['name'] + '"&track:"' + t['name'] +'"'
    #   spotify_track = RSpotify::Track.search(query, limit: 1)[0]
    #   puts 'LastFm: ' + t['artist']['name'] + ' - ' + t['name']
    #   puts 'Spotify: ' + spotify_track.artists[0].name + ' - ' +  spotify_track.name
    #   spotify_tracks << spotify_track
    # end

    @tracks = PlaylistHelper::Recommender.new(users).tracks

    session.generated_playlist = true
    session.save

    session.track_sessions.destroy_all
    session.tracks += @tracks.collect do |t|
      Track.find_by(id: t.id) || Track.new(id: t.id, rspotify_hash: t)
    end
  end

  def play
    session_id = session[:session_id]
    user = UserSession.where(session_id: session_id).order(:created_at).first.spotify_user
    user = RSpotify::User.new(user.rspotify_hash)
    playlist = user.create_playlist!(Time.now.utc.localtime.strftime('%F %R - To-Listen'), public: false)

    session = Session.find_by(id: session_id)
    tracks = session.tracks.order(:created_at)
    playlist.add_tracks!(tracks.collect { |t| t.rspotify_hash })
    redirect_to playlist.external_urls['spotify']
  end
end