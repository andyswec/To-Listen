require 'rspotify'
require 'lastfm'

module PlaylistHelper
  class SpotifyLastFmUser
    attr_reader :spotify_user
    attr_reader :last_fm_user
    attr_reader :spotify_tracks
    attr_reader :last_fm_tracks

    # Creates a SpotifyLastFmUser
    # @param args hash containing :user_session or :spotify_user and last_fm_user
    def initialize(args)
      if !args[:user_session].nil?
        user_session = args[:user_session]
        @spotify_user = RSpotify::User.new(JSON.parse(user_session.spotify_user.rspotify_hash)) unless user_session.spotify_user.nil?
        @last_fm_user = user_session.last_fm_user.last_fm_hash unless user_session.last_fm_user.nil?
      else
        @spotify_user = RSpotify::User.new(JSON.parse(args[:spotify_user].rspotify_hash)) unless spotify_user.nil?
        @last_fm_user = args[:last_fm_user].last_fm_hash unless last_fm_user.nil?
      end

      @spotify_tracks = []
      unless spotify_user.nil?
        i = 0
        begin
          added_tracks = spotify.saved_tracks(limit: 50, offset: i)
          spotify_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end

      @last_fm_tracks = []
      unless last_fm_user.nil?
        i = 1
        begin
          added_tracks = lastfm_api.user.get_top_tracks(user: lastfm['id'], period: '7day', page: i)
          last_fm_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end
    end
  end

  class Recommender
    def initialize(users)
      @users = users
    end

    def get_recommended_tracks
      # TODO
    end
  end
end
