require 'rspotify/oauth'

# set ENV variables in production
CLIENT_ID = ENV['spotify_client_id']
CLIENT_SECRET = ENV['spotify_client_secret']
REDIRECT_URI = ENV['spotify_callback']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, CLIENT_ID, CLIENT_SECRET, show_dialog: true,
      provider_ignores_state: true
end