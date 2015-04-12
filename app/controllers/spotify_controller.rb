require 'json'

class SpotifyController < ApplicationController
  def login
    user_id = params[:id]
    state = !user_id.nil? ? {'user_id' => user_id} : nil

    url = URI.parse 'https://accounts.spotify.com/authorize'
    params = {client_id: CLIENT_ID, response_type: 'code', redirect_uri: REDIRECT_URI, show_dialog: true} #TODO supply scope
    params[:state] = state unless (state.nil?)

    url.query = URI.encode_www_form(params)
    redirect_to url.to_s
  end

  def callback
    error = params[:error]
    code = params[:code]
    state = params[:state]
    user_id = state.nil? ? nil : eval(state)['user_id'].to_i

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

    # Parse response
    User.connection.execute('BEGIN')
    result = User.connection.execute("SELECT * FROM users WHERE id = #{User.sanitize(user_id)}")
    if result.count > 0
      User.connection.execute('COMMIT')
      result = result.first
      user = User.new(id: result['id'], name: result['name'], image: result['image'],
          spotify_id: result['spotify_id'], spotify_access_token: result['spotify_access_token'],
          spotify_refresh_token: result['spotify_refresh_token'], created_at: result['created_at'],
          updated_at: result['updated_at'], last_fm_username: result['last_fm_username'])
    else
      User.connection.execute('ROLLBACK')
      user = User.new
    end


    json = JSON.parse(response.body)

    current_session = Session.new
    current_session.id = session[:session_id]
    view_context.save_session(current_session.id)

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

    old_id = user.id
    view_context.save_user(user)

    user_session = UserSession.new(user_id: user.id, session_id: current_session.id)

    if !old_id.nil? && user.id != old_id
      UserSession.connection.execute('BEGIN')
      result = UserSession.connection.execute("SELECT created_at FROM users_sessions WHERE session_id =
#{UserSession.sanitize(current_session.id)} AND user_id = #{UserSession.sanitize(old_id)}")
      if result.count > 0
        user_session.created_at = result.first['created_at']

        # Remove old user_session
        UserSession.connection.execute("DELETE FROM users_sessions WHERE session_id =
#{UserSession.sanitize(current_session.id)} AND user_id = #{UserSession.sanitize(old_id)}")
      end
    end

    view_context.save_user_session(user_session)


    redirect_to root_path
  end
end