require 'rspotify'

class PlaylistController < ApplicationController
  def playlist
    session_id = session[:session_id]
    session = Session.find(session_id)

    spotify_users = session.spotify_users

    tracks = []
    spotify_users.each do |user|
      user = RSpotify::User.new(JSON.parse(user.rspotify_hash))

      i = 0

      begin
        added_tracks = user.saved_tracks(limit: 50, offset: i)
        tracks += added_tracks
        i += 50
      end while added_tracks.count > 0
    end

    h = Hash.new(0)
    tracks.each { |t| h.store(t.id, h[t.id]+1) }
    tracks.sort_by! { |t| [h[t.id], t.popularity] }.reverse!.uniq! {|t| t.id}

    tracks.each do |t|
      puts h[t.id].to_s + ' ' + t.popularity.to_s + ' ' + t.name
    end

    @tracks = tracks[0..19]

    session.generated_playlist = true
    session.save
  end
end
