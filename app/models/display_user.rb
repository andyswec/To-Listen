require 'rspotify'

class DisplayUser
  attr_reader :name, :image, :image_alt, :last_fm

  def initialize(user_session)
    spotify_user = RSpotify::User.new user_session.spotify_user.rspotify_hash unless user_session.spotify_user.nil?
    last_fm_user = user_session.last_fm_user.last_fm_hash unless user_session.last_fm_user.nil?

    @name = spotify_user.display_name || spotify_user.id unless spotify_user.nil?
    @last_fm = last_fm_user['realname'] || last_fm_user.last_fm_hash['id'] unless last_fm_user.nil?
    @image = !spotify_user.nil? && !spotify_user.images.nil? && spotify_user.images.count > 0 ? spotify_user.images[0]['url'] : "user_avatar.png"
    @image_alt = @image != "user_avatar.png" ? @name + "'s profile image" : "Default profile image"
  end
end