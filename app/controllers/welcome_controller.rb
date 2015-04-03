class WelcomeController < ApplicationController
  def index
    @users = User.joins("JOIN users_sessions us ON us.user_id = users.id").where("us.session_id = ?",
                                                                                 session[:session_id])
  end
end
