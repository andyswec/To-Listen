require 'rspotify'

class DisplayUser
  attr_reader :id, :name, :image, :image_alt, :last_fm_name

  def initialize(user_session)
    spotify_user = RSpotify::User.new user_session.spotify_user.rspotify_hash unless user_session.spotify_user.nil?
    last_fm_user = user_session.last_fm_user

    @id = spotify_user.id
    @name = spotify_user.display_name || spotify_user.id unless spotify_user.nil?
    @last_fm_name = last_fm_user.last_fm_hash['name'] unless last_fm_user.nil?
    @image = !spotify_user.nil? && !spotify_user.images.nil? && spotify_user.images.count > 0 ? spotify_user.images[0]['url'] : "user_avatar.png"
    @image_alt = @image != "user_avatar.png" ? @name + "'s profile image" : "Default profile image"
  end
end