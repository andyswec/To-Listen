require 'rspotify'

class DisplayUser
  attr_reader :id, :spotify_id, :name, :image, :image_alt

  def initialize(user_session)
    spotify_user = RSpotify::User.new user_session.spotify_user.rspotify_hash

    @id = user_session.id
    @spotify_id = spotify_user.id
    @name = spotify_user.display_name || spotify_user.id
    @image = !spotify_user.images.nil? && spotify_user.images.count > 0 ? spotify_user.images[0]['url'] : "user_avatar.png"
    @image_alt = @image != "user_avatar.png" ? @name + "'s profile image" : "Default profile image"
  end
end