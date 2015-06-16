
class PlaylistWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false

  def perform(session_id)
    total 100
    at 0, 'Fetching your tracks'

    session = Session.find(session_id)
    user_sessions = session.user_sessions
    users = []
    user_sessions.each do |us|
      users << PlaylistHelper::SpotifyLastFmUser.new(user_session: us)
    end

    tracks = Set.new
    threads = []

    users.each do |user|
      threads << Thread.new {
        tracks.merge user.tracks.collect { |t| t.object }
      }
    end
    threads.each { |t| t.join }

    at 30, 'Applying black magic to create your playlist'

    threads = []
    count = users.count
    users.each_with_index do |user, index|
      # threads << Thread.new {
      percent = (30 + (((70 - 30) * index).to_f / count)).to_i
      at percent, 'Applying black magic to create your playlist'
      user.calculateRelevances(tracks)
      # }
    end
    # threads.each { |t| t.join }

    at 70, 'Applying black magic to create your playlist'

    tracks = tracks.to_a.sort_by do |t|
      sum = 0
      users.each { |u| sum += u.relevances[t] }
      sum
    end.reverse

    # puts "\nTracks"
    # tracks.each do |t|
    #   sum = 0
    #   values = []
    #   @users.each do |u|
    #     r = u.relevances[t]
    #     values += [r]
    #     sum += r
    #   end
    #   puts sum.to_s + ' ' + values.join(' ') + ' ' + t.to_s
    # end

    at 95, 'Finalizing'

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

    tracks = tracks[0..19]

    session.track_sessions.destroy_all
    session.tracks += tracks.collect do |t|
      Track.find_by(id: t.id) || Track.new(id: t.id, rspotify_hash: t)
    end

    at 100, 'Done'
  end
end