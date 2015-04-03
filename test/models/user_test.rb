require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @session = Session.new(id: "abcd")
    @session.save
    @user = User.new(name: "Andy", image: "http://localhost/image", spotify_id: "123456")
  end

  test "name should be present" do
    @user.name = nil
    assert_not @user.valid?
  end

  test "image should be present" do
    @user.image = nil
    assert_not @user.valid?
  end


  test "spotify ids should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end
end
