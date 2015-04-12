module UsersHelper

  def save_user(user)
    if (user.id.nil?)
      id = User.connection.execute("INSERT INTO users (name, image, spotify_id, spotify_access_token,
spotify_refresh_token, created_at, updated_at, last_fm_username) VALUES (#{User.sanitize (user.name)},
#{User.sanitize(user.image)}, #{User.sanitize(user.spotify_id)}, #{User.sanitize (user.spotify_access_token)},
#{User.sanitize(user.spotify_refresh_token)}, '$NOW', '$NOW', #{User.sanitize(user.last_fm_username)}) RETURNING id")
             .first['id']
      user.id = id
    else
      User.connection.execute("UPDATE users SET (name, image, spotify_id, spotify_access_token,
spotify_refresh_token, created_at, updated_at, last_fm_username) = (#{User.sanitize (user.name)},
#{User.sanitize(user.image)}, #{User.sanitize(user.spotify_id)}, #{User.sanitize (user.spotify_access_token)},
#{User.sanitize(user.spotify_refresh_token)},#{User.sanitize(user.created_at)}, '$NOW',
#{User.sanitize(user.last_fm_username)}) WHERE id = #{User.sanitize(user.id)}")
    end

    user
  end
end