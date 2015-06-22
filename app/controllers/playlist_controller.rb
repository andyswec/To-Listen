require 'rspotify'

class PlaylistController < ApplicationController

  def new
    session_id = session[:session_id]
    session = Session.find(session_id)
    session.generated_playlist = true
    session.save

    job_id = PlaylistWorker.perform_async(session_id)
    render :json => {:job_id => job_id}.to_json
  end

  def playlist
    session_id = session[:session_id]
    session = Session.find_by(id: session_id)
    @tracks = session.track_sessions.order(:position).collect { |ts| ts.track.rspotify_hash }
    @users = session.user_sessions.order(:created_at).collect { |us| DisplayUser.new(us) }
    @warning = flash[:warning]
  end

  def play
    session_id = session[:session_id]
    user_id = params[:user_id]
    user = SpotifyUser.find(user_id)
    user = RSpotify::User.new(user.rspotify_hash)
    playlist = user.create_playlist!(Time.now.utc.localtime.strftime('%F %R - To-Listen'), public: false)

    session = Session.find_by(id: session_id)
    tracks = session.track_sessions.order(:position).collect { |ts| ts.track.rspotify_hash }
    playlist.add_tracks!(tracks)
    redirect_to playlist.external_urls['spotify']
  end

  def percentage
    job_id = params[:job_id]

    if Sidekiq::Status::failed?(job_id)
      render :json => {:status => 'failed', :error => Sidekiq::Status::get(job_id, :error)}.to_json
    elsif Sidekiq::Status::queued?(job_id)
      render :json => {:status => 'queued'}.to_json
    elsif Sidekiq::Status::complete?(job_id)
      warning = Sidekiq::Status::get(job_id, :warning)
      data = Sidekiq::Status::get_all(job_id)
      if (data['total'].to_i == 0)
        percent = 0
      else
        percent = 100 * data['at'].to_i / data['total'].to_i
      end
      message = data['message']

      if warning
        flash[:warning] = warning
      end
      render :json => {:status => 'complete', :percent => percent, :message => message}.to_json
    elsif Sidekiq::Status::working?(job_id)
      data = Sidekiq::Status::get_all(job_id)
      if (data['total'].to_i == 0)
        percent = 0
      else
        percent = 100 * data['at'].to_i / data['total'].to_i
      end
      message = data['message']
      render :json => {:status => 'working', :percent => percent, :message => message}.to_json
    end

    render nothing: true
  end
end