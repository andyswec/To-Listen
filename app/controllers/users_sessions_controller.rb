class UsersSessionsController < ApplicationController
  def destroy
    session_id = session[:session_id]
    position = params[:id].to_i

    user_session = UserSession.where(session_id: session_id).order(:created_at)[position]
    UserSession.delete_all(session_id: session_id, spotify_id: user_session.spotify_id, last_fm_id: user_session
                                                                                                        .last_fm_id)
    redirect_to root_path
  end
end
