require 'rspotify'
require 'lastfm'

module PlaylistHelper
  class SpotifyLastFmUser
    attr_reader :spotify_user
    attr_reader :last_fm_user
    attr_reader :tracks

    # Creates a SpotifyLastFmUser and fetches the songs
    # @param args hash containing :user_session or :spotify_user and last_fm_user
    def initialize(args)
      if !args[:user_session].nil?
        user_session = args[:user_session]
        @spotify_user = RSpotify::User.new(user_session.spotify_user.rspotify_hash) unless user_session.spotify_user.nil?
        @last_fm_user = user_session.last_fm_user.last_fm_hash unless user_session.last_fm_user.nil?
      else
        @spotify_user = RSpotify::User.new(args[:spotify_user].rspotify_hash) unless args[:spotify_user].nil?
        @last_fm_user = args[:last_fm_user].last_fm_hash unless args[:last_fm_user].nil?
      end

      # Fetch spotify tracks
      @tracks = []
      unless @spotify_user.nil?
        i = 0
        begin
          added_tracks = @spotify_user.saved_tracks(limit: 50, offset: i)
          added_at = @spotify_user.tracks_added_at
          @tracks += added_tracks.collect { |o| Track.new(object: o, added_at: added_at[o.id]) }
          i += 50
        end while added_tracks.count == 50

        i = 0
        playlists = []
        begin
          added_playlists = @spotify_user.playlists(limit: 50, offset: i)
          playlists += added_playlists
          i += 50
        end while added_playlists.count == 50

        playlists.each do |p|
          i = 0
          begin
            added_tracks = p.tracks(limit: 100, offset: i)
            added_at = p.tracks_added_at
            @tracks += added_tracks.collect { |o| Track.new(object: o, added_at: added_at[o.id]) }
            i += 100
          end while added_tracks.count == 100
        end
      end
      @tracks.sort_by! { |t| t.object.id.to_s }.reverse!.uniq! { |t| [t.object.artists.collect { |a| a.name }, t.object.name] }

      # Fetch last.fm tracks
      lastfm_api = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)
      @last_fm_tracks = []
      unless @last_fm_user.nil?
        @last_fm_tracks = lastfm_api.user.get_top_tracks(user: @last_fm_user['id'], period: '7day')
        added_tracks.each do |lt|
          index = @tracks.index { |st| st.object.name == lt['name'] && st.object.artists.any? { |sa| sa.name == lt['artist']['name'] } }
          if index.nil?
            puts 'Not found: ' + lt['artist']['name'] + ' - ' + lt['name']
          else
            puts 'Found: ' + @tracks[index].artists.first.name + ' - ' + @tracks[index].name
          end
        end
      end
    end

    def relevance(track)

    end

    private
    def relationship(track)
      return 1 if @tracks.any? do |t|
        !t.object_id.nil? && t.object.id == track.object.id || t.object.name == track.object.name &&
            t.object.artists.collect { |a| a.name } == track.object.artists.collect { |a| a.name }
      end

      return 0.67 if @tracks.any? do |t|
        track.object.artists.collect { |a| a.name } == t.object.artists.collect { |a| a.name }
      end

      return 0.33 if @tracks.any? do |t|
        track.object.artists.collect { |a| a.name }.any? { |a1| t.object.artists.collect { |a2| a2.name }.any? { |a2| a1 == a2 } }
      end

      return 0
    end

    def self.time_coefficient(date)
      weeks = (Time.now.to_i - date.to_i) / (3600 * 24 * 7).to_f
      return 1 if weeks / 2 <= 0
      [1 / (weeks / 2), 1].min
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

      tracks_hash = Hash.new(0)
      spotify_tracks = []
      artists = []
      @users.each do |user|
        user.tracks.each do |t|
          tracks_hash.store(t.object.id, tracks_hash[t.object.id]+1)
          artists += t.object.artists
        end
        spotify_tracks += user.tracks
      end

      spotify_tracks.sort_by! { |t| [tracks_hash[t.object.id], t.object.popularity] }.reverse!.uniq! { |t| t.object.id }

      puts 'Tracks'
      spotify_tracks.each do |t|
        puts tracks_hash[t.object.id].to_s + ' ' + t.object.popularity.to_s + ' ' + t.object.id.to_s + ' ' + t.object.name.to_s
      end

      spotify_tracks[0..19]
    end
  end

  class Track
    attr_reader :object, :added_at

    def initialize(object:, added_at:)
      @object = object
      @added_at = added_at
    end
  end
end
