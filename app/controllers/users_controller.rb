class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    repeat = params[:repeat]
    if @user.blank? or @user.length < 4
      @error = "FAILED: Username should be at least 4 characters."
    end
    if (password.blank? or password.length < 4)
      @error = "FAILED: Password should be at least 4 characters."
    end

    if (password != repeat)
      @error = "FAILED: The entered passwords are not the same."
    end

    if @error
      haml :add_user
    else
      @message = "Congratulations! Your account is created."
      haml :login
    end
  end
  
end

