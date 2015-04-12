module SessionsHelper

  def save_session(id)
    id = Session.sanitize(id)
    Session.connection.execute('BEGIN')
    if Session.connection.execute("SELECT COUNT(*) FROM sessions WHERE id = #{id}").first['count'].to_i == 0
      Session.connection.execute("INSERT INTO sessions (id, created_at, updated_at) VALUES (#{id}, '$NOW', '$NOW')")
      Session.connection.execute("COMMIT")
    else
      Session.connection.execute('ROLLBACK')
    end
  end
end
