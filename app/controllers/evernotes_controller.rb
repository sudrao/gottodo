require ::Rails.root.join('lib', 'evernote_api.rb')

class EvernotesController < ApplicationController
  
  # GET /evernote
  def show
    @token = current_user.evernote
    unless @token
      begin
        req = EvernoteAPI::Request.new(new_evernote_path(:only_path => false))
        @link = req.authorize_url
        # Save request token essentials to use during create
        session[:request_token] = { 'token' => req.request_token.token, 'secret' => req.request_token.secret }
      rescue
        flash[:error] = $!
        @link = nil
      end
    end
    render "oauth/show"
  end
  
  # GET /evernote?new
  # This is the callback action for oauth
  def new
    @verifier = params[:oauth_verifier]
    render "oauth/new"
  end

  # POST /evernote
  # Create and save new credentials for this user
  def create
    begin
      req = EvernoteAPI::Request.new(new_evernote_path(:only_path => false),
        session[:request_token])
      # Now verify with Yammer and get the final access token for user
      @result = "Congratulations - access to Evernote is now set up!"
      begin
        access_token = req.verify(params[:oauth_verifier])
        # save in db for next time
        current_user.evernote = access_token.token, access_token.secret
        if current_user.evernote
          redirect_to :show
        else
          @result = "login or database error - Evernote setup failed."
        end
      rescue
        @result = "Evernote authorization failed!"
      end
    rescue
      flash[:error] = $!
      @result = "We're sorry but something went wrong."
    end
    render "oauth/show"
  end
  
  # DELETE /evernote
  # Remove credentials
  def destroy
    @visitor_home.update_attributes(:yammer_token => nil, :yammer_secret => nil)
    redirect_to :action => 'show'
  end
end