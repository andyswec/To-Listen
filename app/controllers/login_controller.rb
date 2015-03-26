class LoginController < ApplicationController
  def login
    url = URI.parse "https://accounts.spotify.com/authorize"
    url.query = "client_id=#{CLIENT_ID}&response_type=code&redirect_uri=#{REDIRECT_URI}"
    redirect_to url.to_s
  end

  def callback
    code = params[:code]
    puts "Code: #{code}"
  end
end