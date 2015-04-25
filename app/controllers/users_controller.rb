class UsersController < ApplicationController
  def users
    @users_sessions = UserSession.where(session_id: session[:session_id]).order(:created_at)
  end
end