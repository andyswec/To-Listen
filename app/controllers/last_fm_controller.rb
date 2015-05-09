require 'lastfm'

class LastFmController < ApplicationController
  def create
    session_id = session[:session_id]
    last_fm_id = params[:last_fm_username]

    user = LastFmUser.new
    lastfm = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)
    user.last_fm_hash = lastfm.user.get_info(user: last_fm_id)
    user.id = user.last_fm_hash['id']
    user.save

    session = Session.find_by(id: session_id)
    if (session.nil?)
      session = Session.new(id: session_id)
      session.save
    end

    user_session = UserSession.new(last_fm_id: user.id, session_id: session_id)
    if !user_session.save # TODO send error message
      render nothing: true
    else
      @users_count = session.user_sessions.count
      @position = @users_count - 1
      @user_session = user_session
    end
  end

  def update
    position = params[:id].to_i # TODO user_id is in fact a position
    last_fm_username = params[:last_fm_username]
    session_id = session[:session_id]

    session = Session.find_by(id: session_id)
    if (session.nil?)
      session = Session.new(id: session_id)
      session.save
    end

    lastfm = Lastfm.new(LAST_FM_API_ID, LAST_FM_CLIENT_SECRET)
    last_fm_hash = lastfm.user.get_info(user: last_fm_username)
    user = LastFmUser.find_by(id: last_fm_hash['id'])
    user = LastFmUser.new(id: last_fm_hash['id']) if user.nil?
    user.last_fm_hash = last_fm_hash
    user.save

    us = UserSession.where(session_id: session_id).order(:created_at)[position]
    us.last_fm_user = user
    us.save # TODO send fail if !us.save

    @position = position
    @name = user.last_fm_hash['realname']
  end
end