require 'rspotify'
require 'lastfm'
require 'sidekiq'
require 'sidekiq-status'

module PlaylistHelper

  class SpotifyLastFmUser
    attr_reader :spotify_user, :last_fm_user, :tracks, :relevances

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
    end

    def tracks
      @tracks ||= fetchTracks
    end

    def fetchTracks
      # Fetch spotify tracks
      tracks = []
      threads = []
      unless @spotify_user.nil?
        threads << Thread.new {
          i = 0
          begin
            added_tracks = @spotify_user.saved_tracks(limit: 50, offset: i)
            added_at = @spotify_user.tracks_added_at
            tracks += added_tracks.collect { |o| RelevanceTrack.new(object: o, added_at: added_at[o.id], added_by_user: true) }
            i += 50
          end while added_tracks.count == 50
        }

        j = 0
        playlists = []
        begin
          added_playlists = @spotify_user.playlists(limit: 50, offset: j)
          playlists += added_playlists
          j += 50
        end while added_playlists.count == 50

        playlists.each do |p|
          threads << Thread.new {
            i = 0
            begin
              added_tracks = p.tracks(limit: 100, offset: i)
              added_at = p.tracks_added_at
              added_by = p.tracks_added_by
              tracks += added_tracks.collect { |o| RelevanceTrack.new(object: o, added_at: added_at[o.id], added_by_user: added_by[o.id].id == @spotify_user.id) }
              i += 100
            end while added_tracks.count == 100
          }
        end
      end

      threads.each { |t| t.join }

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

      tracks
    end

    def calculateRelevances(tracks)
      @relevances = {}
      min = nil
      max = nil

      tracks.each do |t|
        r = relevance(t)
        min = r if min.nil? || r < min
        max = r if max.nil? || r > max
        @relevances.store(t, r)
      end

      old_range = (max - min)
      new_range = 1
      @relevances = Hash[@relevances.map { |k, v| [k, new_value = ((v - min) * new_range) / old_range] }]
    end

    private
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

    def self.time_coefficient(date)
      weeks = (Time.now.to_i - date.to_i) / (3600 * 24 * 7).to_f
      return 1 if weeks / 2 <= 0
      [1 / (weeks / 2), 1].min
    end
  end


  class RelevanceTrack
    attr_reader :object, :added_at, :added_by_user

    def initialize(options)
      @object = options[:object]
      @added_at = options[:added_at]
      @added_by_user = options[:added_by_user]
    end
  end


  class RSpotify::Track

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
      0
    end

    def to_s
      @artists.join(',') + ' - ' + @name
    end

    alias_method :eql?, :==

    protected
    def state
      [@name, @artists]
    end
  end

  class RSpotify::Artist

    def ==(o)
      o.class == self.class && o.state == state
    end

    def hash
      state.hash
    end

    def to_s
      @name
    end

    alias_method :eql?, :==

    protected
    def state
      @name
    end
  end
end
