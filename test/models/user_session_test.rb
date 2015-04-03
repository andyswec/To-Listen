require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  def setup
    @user_session = UserSession.new(user_id: 1, session_id: "bbb")
  end

  test "user_id and session_id combination should be unique" do
    duplicate = @user_session.dup
    @user_session.save
    assert_not duplicate.valid?
  end
end
