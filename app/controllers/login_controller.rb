class LoginController < ApplicationController
  skip_before_filter :authenticate, :except => :destroy
  respond_to :html, :xml
  
  def show
  end
  
  def new
  end
  
  def delete
    sign_out
    redirect_to '/main', :notice => "Sign out successful"
  end
  
end
    