require 'json'

class SpotifyController < ApplicationController
  def login
    url = URI.parse "https://accounts.spotify.com/authorize"
    params = {:client_id => "#{CLIENT_ID}", :response_type => "code", :redirect_uri => "#{REDIRECT_URI}"} #TODO supply scope and state
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
    # puts "Request: " + request.body
    response = http.request(request)

    # puts "Response: " + response.body
    return unless response.kind_of? Net::HTTPSuccess

    user = User.new

    json = JSON.parse(response.body)

    current_session = Session.new
    current_session.id = session[:session_id]
    current_session.save

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
    user.image = json['images'].first['url']
    user.spotify_id = json['id']

    user.save

    user_session = UserSession.new(user_id: user.id, session_id: current_session.id)
    user_session.save

    redirect_to root_path
  end
end