class UsersSessionsController < ApplicationController
  def create
    session_id = session[:session_id]
    last_fm_id = params[:last_fm_username]

    @user = User.new(last_fm_username: last_fm_id) # TODO get name and image from last.fm
    @user.save

    session = Session.new(id: session_id)
    session.save

    user_session = UserSession.new(user_id: @user.id, session_id: session_id)
    if !user_session.save # TODO send error message
      render nothing: true
    else
      render partial: 'users/user', locals: {user: @user}
    end
  end

  def destroy
    session_id = session[:session_id]
    position = params[:id].to_i

    user_session = UserSession.where(session_id: session_id).order(:created_at)[position]
    UserSession.delete_all(session_id: session_id, spotify_id: user_session.spotify_id, last_fm_id: user_session
                                                                                                        .last_fm_id)
    redirect_to root_path
  end

  def update
    id = params[:user_id] # TODO id is in fact a position
    last_fm_id = params[:last_fm_username]

    user = User.find(id)
    user.last_fm_username = last_fm_id
    user.save

    render nothing: true
  end
end