require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  def setup
    @user_session = UserSession.new(user_id: 1, session_id: "bbb", position: 1)
  end

  test "user_id should be present" do
    @user_session.user_id = nil
    assert_not @user_session.valid?
  end

  test "session_id should be present" do
    @user_session.session_id = nil
    assert_not @user_session.valid?
  end

  test "position should be present" do
    @user_session.session_id = nil
    assert_not @user_session.valid?
  end

  test "user_id and session_id combination should be unique" do
    duplicate = @user_session.dup
    duplicate.position = @user_session.position + 1
    @user_session.save
    assert_not duplicate.valid?
  end

  test "session_id and position combination should be unique" do
    duplicate = @user_session.dup
    duplicate.user_id = @user_session.user_id + 1
    @user_session.save
    assert_not duplicate.valid?
  end

  test "distinct user_id and position with the same user_id should be accepted" do
    duplicate = @user_session.dup
    duplicate.user_id = @user_session.user_id + 1
    duplicate.position = @user_session.position + 1
    @user_session.save
    assert duplicate.valid?
  end
end
