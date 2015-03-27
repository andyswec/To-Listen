require 'test_helper'

class SpotifyControllerTest < ActionController::TestCase
  test "should get spotify" do
    get :spotify
    assert_response :success
  end

  test "should get callback" do
    get :callback
    assert_response :success
  end

end
