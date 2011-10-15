class UsersController < ApplicationController
  skip_before_filter :authenticate, :only => [:create]

  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:notice] = "Congratulations! Your account is created."
      redirect_to "mains#show"
    else
      render "login#show"
    end
  end
  
end

