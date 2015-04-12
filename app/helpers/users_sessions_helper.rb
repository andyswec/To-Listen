module UsersSessionsHelper
  def save_user_session(user_session)
    UserSession.connection.execute('BEGIN')
    if (UserSession.connection.execute("SELECT COUNT(*) FROM users_sessions WHERE user_id =
#{UserSession.sanitize (user_session.user_id)} AND session_id = #{UserSession.sanitize(user_session.session_id)}")
          .first['count'].to_i == 0)
      UserSession.connection.execute("INSERT INTO users_sessions (user_id, session_id, created_at, updated_at) =
(#{UserSession.sanitize(user_session.user_id)}, #{UserSession.sanitize(user_session.session_id)}, '$NOW', '$NOW')")
      UserSession.connection.execute('COMMIT')
    else
      UserSession.connection.execute('ROLLBACK')
    end
  end
end
