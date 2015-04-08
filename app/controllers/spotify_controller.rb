require 'json'

class SpotifyController < ApplicationController
  def login
    url = URI.parse "https://accounts.spotify.com/authorize"
    params = { client_id: "#{CLIENT_ID}", response_type: "code", redirect_uri: "#{REDIRECT_URI}",
        show_dialog: true } #TODO
    # supply scope and state
    url.query = URI.encode_www_form(params)
    redirect_to url.to_s
  end

  def callback
    error = params[:error]
    code = params[:code]

    return if code.nil?

    uri = URI.parse("https://accounts.spotify.com/api/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path)
    request.add_field('Content-Type', 'application/json')
    request.set_form_data(:grant_type => "authorization_code", :code => "#{code}", :redirect_uri => "#{REDIRECT_URI}")
    request.basic_auth("#{CLIENT_ID}", "#{CLIENT_SECRET}")
    response = http.request(request)

    # puts "Response: " + response.body
    return unless response.kind_of? Net::HTTPSuccess

    user = User.new

    json = JSON.parse(response.body)

    current_session = Session.new
    current_session.id = session[:session_id]
    Session.connection.execute("BEGIN")
    if current_session.valid? && Session.connection.execute("SELECT COUNT(*) FROM sessions s WHERE s.id = #{Session
                                                                                                                .sanitize(current_session.id)}").count == 0
      Session.connection.execute("INSERT INTO sessions (id, created_at, updated_at) VALUES ('#{Session.sanitize
          (current_session.id)}', '$NOW', '$NOW')")
      Session.connection.execute("COMMIT")
    else
      Session.connection.execute("ROLLBACK")
    end

    user.spotify_access_token = json['access_token']
    user.spotify_refresh_token = json['refresh_token']

    uri = URI.parse("https://api.spotify.com/v1/me")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request_get(uri.path, "Authorization" => "Bearer #{user.spotify_access_token}")
    # puts "Response: " + response.body

    return unless response.kind_of? Net::HTTPSuccess

    json = JSON.parse(response.body)
    user.name = json['display_name']
    user.image = json['images'].first['url'] unless json['images'].first.nil?
    user.spotify_id = json['id']

    unless user.save
      user = User.find_by(spotify_id: user.spotify_id)
    end

    user_session = UserSession.new(user_id: user.id, session_id: current_session.id)
    UserSession.connection.execute("BEGIN")
    position = UserSession.connection.execute("SELECT MAX(us.position)+1 as position FROM users_sessions us WHERE us
.session_id = #{UserSession.sanitize(user_session.session_id)} GROUP BY us.position")
    user_session.position = position.first == nil ? 1 : position.first['position']
    sql = "INSERT INTO users_sessions (user_id, session_id, position, created_at, updated_at) VALUES
(#{UserSession.sanitize(user_session.user_id)}, #{UserSession.sanitize(user_session.session_id)},
#{UserSession.sanitize(user_session.position)}, '$NOW', '$NOW')"
    if user_session.valid?
      UserSession.connection.execute(sql)
    end
    UserSession.connection.execute("COMMIT")

    redirect_to root_path
  end
end