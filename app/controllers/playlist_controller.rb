require 'rspotify'
require 'lastfm'

class PlaylistController < ApplicationController

  def new
    session_id = session[:session_id]
    session = Session.find(session_id)
    session.generated_playlist = true
    session.save

    @job_id = PlaylistHelper::PlaylistWorker.perform_async(session_id)
  end

  def playlist
    session_id = session[:session_id]
    session = Session.find_by(id: session_id)
    @tracks = session.tracks.order(:created_at).collect { |t| t.rspotify_hash }
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

  def percentage
    job_id = params[:job_id]
    data = Sidekiq::Status::get_all(job_id)
    if (data['total'] == 0)
      percent = 0
    else
      percent = 100 * data['at'].to_i / data['total'].to_i
    end
    message = data['message']
    render :json => {:percent => percent, :message => message}.to_json
  end
end