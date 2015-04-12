require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get Stats" do
    get :stats
    assert_response :success
  end

end
