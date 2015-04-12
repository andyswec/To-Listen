class UsersSessionsController < ApplicationController
  def create
    session_id = session[:session_id]
    last_fm_id = params[:last_fm_username]

    @user = User.new
    @user.last_fm_username = last_fm_id
    @user = view_context.save_user(@user)

    session = Session.new(id: session_id)
    view_context.save_session(session)

    user_session = UserSession.new(user_id: @user.id, session_id: session_id)
    view_context.save_user_session(user_session)

    render partial: 'users/user', locals: {user: @user}
  end

  def destroy
    session_id = session[:session_id]
    user_id = params[:id]

    UserSession.connection.execute("DELETE FROM users_sessions WHERE session_id =
#{UserSession.sanitize(session_id)} AND user_id = #{UserSession.sanitize(user_id)}")

    redirect_to root_path
  end

  def update
    id = params[:user_id]
    last_fm_id = params[:last_fm_username]

    User.connection.execute("UPDATE users SET last_fm_username = #{User.sanitize(last_fm_id)} WHERE id = #{User.sanitize(id)}")

    render nothing: true
  end
end