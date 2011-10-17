class UsersController < ApplicationController
  skip_before_filter :authenticate, :only => [:create]

  def create
    @user = User.new(params[:user])
    
    if @user.save
      redirect_to "/main", :notice => "Congratulations! Your account is created."
    else
      render "mains/show"
    end
  end
  
end

