require 'rspotify'

class UsersController < ApplicationController
  def users
    users_sessions = UserSession.where(session_id: session[:session_id]).order(:created_at)
    @display_users = users_sessions.collect { |us| DisplayUser.new(us) }
    @alert = flash[:alert]
  end
end