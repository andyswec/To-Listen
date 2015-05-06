require 'rspotify'
require 'lastfm'

class PlaylistController < ApplicationController
  include PlaylistHelper
  def playlist
    lastfm_api = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)

    session_id = session[:session_id]
    session = Session.find(session_id)

    user_sessions = session.user_sessions

    users = []
    user_sessions.each do |us|
      users << SpotifyLastFmUser.new(user_session: us)
    end

    # last_fm_tracks.each do |t|
    #   query = 'artist:"' + t['artist']['name'] + '"&track:"' + t['name'] +'"'
    #   spotify_track = RSpotify::Track.search(query, limit: 1)[0]
    #   puts 'LastFm: ' + t['artist']['name'] + ' - ' + t['name']
    #   puts 'Spotify: ' + spotify_track.artists[0].name + ' - ' +  spotify_track.name
    #   spotify_tracks << spotify_track
    # end

    h = Hash.new(0)
    spotify_tracks.each { |t| h.store(t.id, h[t.id]+1) }
    spotify_tracks.sort_by! { |t| [h[t.id], t.popularity] }.reverse!.uniq! { |t| t.id }

    spotify_tracks.each do |t|
      puts h[t.id].to_s + ' ' + t.popularity.to_s + ' ' + t.id + ' ' + t.name
    end

    @tracks = spotify_tracks[0..19]

    session.generated_playlist = true
    session.save
  end

  def play
    user = UserSession.where(session_id: session[:session_id]).order(:created_at).first.spotify_user
    user = user.to_rspotify_user
    playlist = user.create_playlist!(Time.now.utc.localtime.strftime('%F %R - To-Listen'), public: false)

    playlist()
    playlist.add_tracks!(@tracks)
    redirect_to playlist.external_urls['spotify']
  end
end
