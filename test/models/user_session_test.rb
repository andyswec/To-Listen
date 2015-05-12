require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  def setup
    @user_session = UserSession.new(session_id: 'bbb', spotify_id: 'andy', last_fm_id: 'andy')
  end

  test 'spotify_id or last_fm_id should be present' do
    @user_session.spotify_user = nil
    @user_session.last_fm_user = nil
    assert_not @user_session.valid?
  end

  test 'user_session with spotify_id only should be valid' do
    @user_session.spotify_user = nil
    assert @user_session.valid?
  end

  test 'user_session with last_fm_id only should be valid' do
    @user_session.last_fm_user = nil
    assert @user_session.valid?
  end

  test "session_id should be present" do
    @user_session.session_id = nil
    assert_not @user_session.valid?
  end

  test "spotify_id and session_id combination should be unique" do
    @user_session.last_fm_user = nil
    duplicate = @user_session.dup
    @user_session.save
    assert_not duplicate.valid?
  end

  test "last_fm_id and session_id combination should be unique" do
    @user_session.spotify_user = nil
    duplicate = @user_session.dup
    @user_session.save
    assert_not duplicate.valid?
  end

  test "user with different spotify_id should be allowed in the same session" do
    @user_session.last_fm_user = nil
    duplicate = @user_session.dup
    @user_session.save
    duplicate.spotify_id = 'luci'
    assert duplicate.valid?
  end
end
