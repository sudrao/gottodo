class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate
  
  def authenticate
    unless signed_in?
      user = User.find_by_login(params)
      if user
        sign_in(user)
      else
        redirect_to login_path
      end
    end
  end
      
end
