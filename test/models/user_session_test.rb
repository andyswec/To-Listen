require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  def setup
    @user_session = UserSession.new(session_id: 'bbb', spotify_user: spotify_users(:andy))
  end

  test 'spotify_id should be present' do
    @user_session.spotify_user = nil
    assert_not @user_session.valid?
  end

  test "session_id should be present" do
    @user_session.session_id = nil
    assert_not @user_session.valid?
  end

  test "spotify_id and session_id combination should be unique" do
    duplicate = @user_session.dup
    @user_session.save
    assert_not duplicate.valid?
  end

  test "user with different spotify_id should be allowed in the same session" do
    duplicate = @user_session.dup
    @user_session.save
    duplicate.spotify_user = spotify_users(:luci)
    assert duplicate.valid?
  end
end
