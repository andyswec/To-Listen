class UsersSessionsController < ApplicationController
  def destroy
    session_id = session[:session_id]
    user_id = params[:id]

    UserSession.connection.execute("DELETE FROM users_sessions WHERE session_id =
#{UserSession.sanitize(session_id)} AND user_id = #{UserSession.sanitize(user_id)}")

    redirect_to root_path
  end
end