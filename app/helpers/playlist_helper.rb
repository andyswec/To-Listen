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
          @tracks += added_tracks.collect { |o| Track.new(object: o, added_at: added_at[o.id], added_by_user: true) }
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
            added_by = p.tracks_added_by
            @tracks += added_tracks.collect { |o| Track.new(object: o, added_at: added_at[o.id], added_by_user: added_by[o.id].id == @spotify_user.id) }
            i += 100
          end while added_tracks.count == 100
        end
      end

      # Fetch last.fm tracks
      # lastfm_api = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)
      # @last_fm_tracks = []
      # unless @last_fm_user.nil?
      #   @last_fm_tracks = lastfm_api.user.get_top_tracks(user: @last_fm_user['id'], period: '7day')
      #   added_tracks.each do |lt|
      #     index = @tracks.index { |st| st.object.name == lt['name'] && st.object.artists.any? { |sa| sa.name == lt['artist']['name'] } }
      #     if index.nil?
      #       puts 'Not found: ' + lt['artist']['name'] + ' - ' + lt['name']
      #     else
      #       puts 'Found: ' + @tracks[index].artists.first.name + ' - ' + @tracks[index].name
      #     end
      #   end
      # end

      @tracks

    end

    def relevance(track)
      best = 0
      @tracks.each do |t|
        similarity = t.object.similarity(track)
        time = self.class.time_coefficient(t.added_at)
        mine = t.added_by_user ? 1 : 0
        best = [best, similarity * time * mine].max
      end

      return best
    end

    private
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
      tracks = Set.new
      @users.each do |user|
        tracks.merge user.tracks.collect { |t| t.object }
      end

      tracks = tracks.to_a.sort_by do |t|
        sum = 0
        @users.each { |u| sum += u.relevance(t) }
        sum
      end.reverse

      # puts "\nTracks"
      # tracks.each do |t|
      #   sum = 0
      #   values = []
      #   @users.each do |u|
      #     r = u.relevance(t)
      #     values += [r]
      #     sum += r
      #   end
      #   puts sum.to_s + ' ' + values.join(' ') + ' ' + t.to_s
      # end

      i = 0
      until i >= 20 do
        t = tracks[i]
        break if t.nil?

        if t.id.nil?
          query = "artist:#{t.artists.join(' ')} track:#{t}"
          result = RSpotify::Track.search(query, limit: 1)
          if result.empty?
            tracks.delete_at i
          else
            tracks[i] = result.first
            i += 1
          end
        else

          i += 1
        end
      end

      tracks[0..19]
    end
  end

  class Track
    attr_reader :object, :added_at, :added_by_user

    def initialize(object:, added_at:, added_by_user:)
      @object = object
      @added_at = added_at
      @added_by_user = added_by_user
    end
  end

  class RSpotify::Track
    alias_method :eql?, :==

    def ==(o)
      o.class == self.class && o.state == state
    end

    def hash
      state.hash
    end

    def similarity(o)
      return 1 if self == o
      return 0.67 if self.artists == o.artists
      return 0.33 if self.artists.product(o.artists).any? { |a1, a2| a1 == a2 }
      return 0
    end

    def to_s
      return @artists.join(',') + ' - ' + @name
    end

    protected
    def state
      [@name, @artists]
    end
  end

  class RSpotify::Artist
    alias_method :eql?, :==

    def ==(o)
      o.class == self.class && o.state == state
    end

    def hash
      state.hash
    end

    def to_s
      return @name
    end

    protected
    def state
      @name
    end
  end
end
