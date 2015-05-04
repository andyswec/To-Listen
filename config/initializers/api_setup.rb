require 'rspotify/oauth'

# set ENV variables in production
SPOTIFY_CLIENT_ID = ENV['spotify_client_id']
SPOTIFY_CLIENT_SECRET = ENV['spotify_client_secret']
SPOTIFY_REDIRECT_URI = ENV['spotify_callback']

LAST_FM_API_ID = ENV['lastfm_api_id']
LAST_FM_CLIENT_SECRET = ENV['lastfm_api_secret']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET, show_dialog: true,
      provider_ignores_state: true
end