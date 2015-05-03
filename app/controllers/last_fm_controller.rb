class LastFmController < ApplicationController
  def create
    session_id = session[:session_id]
    last_fm_id = params[:last_fm_username]

    user = LastFmUser.new(id: last_fm_id) # TODO get name and image from last.fm
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
      count = session.user_sessions.count
      render partial: 'users/user', locals: {user_session: user_session, users_count: count, position: (count-1)}
    end
  end

  def update
    position = params[:id].to_i # TODO user_id is in fact a position
    last_fm_id = params[:last_fm_username]
    session_id = session[:session_id]

    session = Session.find_by(id: session_id)
    if (session.nil?)
      session = Session.new(id: session_id)
      session.save
    end

    user = LastFmUser.find_by(id: last_fm_id)
    if user.nil?
      user = LastFmUser.new(id: last_fm_id) if user.nil?
      user.id = last_fm_id
      user.save
    end

    us = UserSession.where(session_id: session_id).order(:created_at)[position]
    us.last_fm_user = user
    us.save
  end
end