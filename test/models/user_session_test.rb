require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  def setup
    @user_session = UserSession.new(session_id: 'bbb', spotify_id: 'andy', last_fm_id:'andy')
  end

  test "user_id should be present" do
    @user_session.spotify_user = nil
    @user_session.last_fm_user = nil
    assert_not @user_session.valid?
  end

  test "session_id should be present" do
    @user_session.session_id = nil
    assert_not @user_session.valid?
  end

  test "user_id and session_id combination should be unique" do
    duplicate = @user_session.dup
    @user_session.save
    assert_not duplicate.valid?
  end
end
