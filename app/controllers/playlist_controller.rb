require 'rspotify'
require 'lastfm'

class PlaylistController < ApplicationController
  def playlist
    lastfm_api = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)

    session_id = session[:session_id]
    session = Session.find(session_id)

    user_sessions = session.user_sessions

    spotify_tracks = []
    last_fm_tracks = []
    user_sessions.each do |us|

      spotify = RSpotify::User.new(JSON.parse(us.spotify_user.rspotify_hash)) unless us.spotify_user.nil?
      lastfm = us.last_fm_user
      lastfm.last_fm_hash = lastfm.to_hash unless lastfm.nil?

      # Get spotify tracks
      if !spotify.nil?
        i = 0
        begin
          added_tracks = spotify.saved_tracks(limit: 50, offset: i)
          spotify_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end

      # Get Last.fm tracks
      if !lastfm.nil?
        i = 1
        begin
          added_tracks = lastfm_api.user.get_top_tracks(user: lastfm['id'], period: '3month', page: i)
          last_fm_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end
    end

    last_fm_tracks.each do |t|
      puts t['name']
    end

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
