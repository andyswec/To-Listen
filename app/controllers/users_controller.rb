class UsersController < ApplicationController
  def users
    @users = User.all
  end
end