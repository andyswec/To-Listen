class UsersSessionsController < ApplicationController
  def destroy
    session_id = session[:session_id]
    id = params[:id].to_i

    UserSession.delete_all(session_id: session_id, id: id)
    redirect_to root_path
  end
end
