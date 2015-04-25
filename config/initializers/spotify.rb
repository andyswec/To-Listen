require 'rspotify/oauth'

CLIENT_ID = ENV['spotify_client_id']
CLIENT_SECRET = ENV['spotify_client_secret']
REDIRECT_URI = ENV['spotify_callback']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, CLIENT_ID, CLIENT_SECRET, scope: 'user-read-email', show_dialog: true, provider_ignores_state: true
end