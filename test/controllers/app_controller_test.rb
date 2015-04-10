require 'test_helper'

class AppControllerTest < ActionController::TestCase
  test "should get users" do
    get root
    assert_response :success
  end

end
