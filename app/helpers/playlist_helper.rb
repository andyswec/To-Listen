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
        @spotify_user = RSpotify::User.new(user_session.spotify_user.rspotify_hash) unless user_session.spotify_user.nil?
        @last_fm_hash = user_session.last_fm_user.last_fm_hash unless user_session.last_fm_user.nil?
      else
        @spotify_user = RSpotify::User.new(args[:spotify_user].rspotify_hash) unless spotify_user.nil?
        @last_fm_hash = args[:last_fm_user].last_fm_hash unless args[:last_fm_user].nil?
      end

      @spotify_tracks = []
      unless @spotify_user.nil?
        i = 0
        begin
          added_tracks = @spotify_user.saved_tracks(limit: 50, offset: i)
          @spotify_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end

      lastfm_api = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)
      @last_fm_tracks = []
      unless last_fm_user.nil?
        i = 1
        begin
          added_tracks = lastfm_api.user.get_top_tracks(user: @last_fm_hash['id'], period: '7day', page: i)
          @last_fm_tracks += added_tracks
          i += 50
        end while added_tracks.count == 50
      end
    end
  end

  class Recommender
    attr_reader :tracks

    def initialize(users)
      @users = users
    end

    def tracks
      @tracks ||= get_recommended_tracks
    end

    private
    def get_recommended_tracks
      # TODO :)

      h = Hash.new(0)
      spotify_tracks = []
      @users.each do |user|
        user.spotify_tracks.each { |t| h.store(t.id, h[t.id]+1) }
        spotify_tracks += user.spotify_tracks
      end

      spotify_tracks.sort_by! { |t| [h[t.id], t.popularity] }.reverse!.uniq! { |t| t.id }

      spotify_tracks.each do |t|
        puts h[t.id].to_s + ' ' + t.popularity.to_s + ' ' + t.id + ' ' + t.name
      end

      spotify_tracks[0..19]
    end
  end
end
