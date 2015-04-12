module UsersHelper

  def save_user(user)
    if (user.id.nil?)
      User.connection.execute("BEGIN")
      spotify_cond = "spotify_id " + (user.spotify_id.nil? ? "IS NULL" : "= #{User.sanitize(user.spotify_id)}")
      last_fm_cond = "last_fm_username " + (user.last_fm_username.nil? ? "IS NULL" : "= #{User.sanitize(user.last_fm_username)}")
      result = User.connection.execute("SELECT * FROM users WHERE #{spotify_cond} AND #{last_fm_cond}")

      if result.count > 0
        result = result.first
        user.id = result['id']
        user.name = result['name']
        user.image = result['image']
        user.spotify_id = result['spotify_id']
        user.spotify_access_token = result['spotify_access_token']
        user.spotify_refresh_token = result['spotify_refresh_token']
        user.created_at = result['created_at']
        user.updated_at = result['updated_at']
        user.last_fm_username = result['last_fm_username']
        User.connection.execute("ROLLBACK")
      else
        id = User.connection.execute("INSERT INTO users (name, image, spotify_id, spotify_access_token,
spotify_refresh_token, created_at, updated_at, last_fm_username) VALUES (#{User.sanitize (user.name)},
#{User.sanitize(user.image)}, #{User.sanitize(user.spotify_id)}, #{User.sanitize (user.spotify_access_token)},
#{User.sanitize(user.spotify_refresh_token)}, '$NOW', '$NOW', #{User.sanitize(user.last_fm_username)}) RETURNING id")
                 .first['id']
        user.id = id
        User.connection.execute('COMMIT')
      end
    else
      User.connection.execute('BEGIN')
      spotify_cond = "spotify_id " + (user.spotify_id.nil? ? "IS NULL" : "= #{User.sanitize(user.spotify_id)}")
      last_fm_cond = "last_fm_username " + (user.last_fm_username.nil? ? "IS NULL" : "= #{User.sanitize(user.last_fm_username)}")
      result = User.connection.execute("SELECT * FROM users WHERE #{spotify_cond} AND #{last_fm_cond}")

      if result.count > 0
        result = result.first
        user.id = result['id']
        user.name = result['name']
        user.image = result['image']
        user.spotify_id = result['spotify_id']
        user.spotify_access_token = result['spotify_access_token']
        user.spotify_refresh_token = result['spotify_refresh_token']
        user.created_at = result['created_at']
        user.updated_at = result['updated_at']
        user.last_fm_username = result['last_fm_username']
        User.connection.execute("ROLLBACK")
      else
        User.connection.execute("UPDATE users SET (name, image, spotify_id, spotify_access_token,
spotify_refresh_token, created_at, updated_at, last_fm_username) = (#{User.sanitize (user.name)},
#{User.sanitize(user.image)}, #{User.sanitize(user.spotify_id)}, #{User.sanitize (user.spotify_access_token)},
#{User.sanitize(user.spotify_refresh_token)},#{User.sanitize(user.created_at)}, '$NOW',
#{User.sanitize(user.last_fm_username)}) WHERE id = #{User.sanitize(user.id)}")
      end
    end

    user
  end
end