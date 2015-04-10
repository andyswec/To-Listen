class UsersSessionsController < ApplicationController
  def create
    session_id = session[:session_id]
    last_fm_id = params[:last_fm_username]

    @user = User.new
    @user.last_fm_username = last_fm_id

    User.connection.execute("BEGIN")
    if (@user.valid?)
      id = User.connection.insert_sql("INSERT INTO users (last_fm_username, created_at, updated_at) VALUES (
#{User.sanitize(@user.last_fm_username)}, '$NOW', '$NOW')")

      if (Session.connection.execute("SELECT COUNT(*) FROM sessions WHERE id = #{Session.sanitize(session_id)}").first['count'] == 0)
        Session.connection.insert_sql("INSERT INTO sessions (id, created_at, updated_at) VALUES (
#{Session.sanitize(session_id)}, '$NOW', '$NOW')")
      end

      UserSession.connection.insert_sql("INSERT INTO users_sessions (session_id, user_id, created_at,
updated_at) VALUES (#{UserSession.sanitize (session_id)},#{id}, '$NOW', '$NOW')")
      User.connection.execute("COMMIT")
      @user.id = id
    else
      User.connection.execute("ROLLBACK")
    end

    render partial: 'users/user', locals: {user: @user}
  end

  def destroy
    session_id = session[:session_id]
    user_id = params[:id]

    UserSession.connection.execute("DELETE FROM users_sessions WHERE session_id =
#{UserSession.sanitize(session_id)} AND user_id = #{UserSession.sanitize(user_id)}")

    redirect_to root_path
  end
end