class LoginController < ApplicationController
  skip_before_filter :authenticate, :except => :destroy
  respond_to :html, :xml
  
  def show
  end
  
  def new
  end
=begin  
  def create
    @user = User.find_by_login(params)
    
    respond_with(@user) do |format|
      if @user
        sign_in()
=end
end
    