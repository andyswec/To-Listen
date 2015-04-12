class UsersController < ApplicationController
  def users
    sql = "SELECT * FROM users u JOIN users_sessions us ON us.user_id = u.id WHERE us.session_id = #{User.sanitize(session[:session_id])} ORDER BY us.created_at ASC"
    result = ActiveRecord::Base.connection.execute(sql)

    @users = []
    result.each do |user|
      @users << User.new(id: user['id'], name: user['name'], image: user['image'], spotify_id: user['spotify_id'],
          spotify_access_token: user['spotify_access_token'], spotify_refresh_token: user['spotify_refresh_token'],
          created_at: user['created_at'], updated_at: user['updated_at'], last_fm_username: user['last_fm_username'])
    end
  end
end