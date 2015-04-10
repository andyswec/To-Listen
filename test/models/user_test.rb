require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @session = Session.new(id: "abcd")
    @session.save
    @user = User.new(name: "Andy", image: "http://localhost/image", spotify_id: "123456", last_fm_username: "andy")
  end

  test "spotify id or last fm username shoud be present" do
    @user.last_fm_username = nil
    assert @user.valid?, "user with spotify id should be valid"
    @user.spotify_id = nil
    @user.last_fm_username = "andy"
    assert @user.valid?, "user with last_fm_username should be valid"
    @user.last_fm_username = nil
    assert_not @user.valid?
  end
end
