require 'test_helper'

class SpotifyUserTest < ActiveSupport::TestCase
  def setup
    @user = SpotifyUser.new(id: 1234, rspotify_hash: {displayName: '1234_display_name'})
  end

  test 'id should be present' do
    @user.id = nil
    assert_not @user.valid?
  end

  test 'id should be unique' do
    dup = @user.dup
    @user.save
    assert_not dup.valid?
  end
end
