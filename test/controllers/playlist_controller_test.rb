require 'test_helper'

class PlaylistControllerTest < ActionController::TestCase
  test "should get playlist" do
    get :playlist
    assert_response :success
  end

end
