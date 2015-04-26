require 'test_helper'

class PlaylistControllerTest < ActionController::TestCase
  def setup
    session[:session_id] = 'aaa'
  end

  test "should get playlist" do
    get :playlist
    assert_response :success
  end

end
