class MainsController < ApplicationController
  
  def show
  end   

=begin

get '/:user' do
  if valid_user?
    r = @@redis
    @userid = session[:user]
    @username = r.get username_key(@userid)
    @pending = r.smembers pending_key(@userid)
    @complete = r.smembers complete_key(@userid)
    haml :index
  else
    haml :login
  end
end

post '/login' do
  # Authenticate, then
  realname, userid = authenticate(params[:user], params[:password])
  session[:user] = userid
  if userid
    redirect "/#{userid}-#{params[:user]}"
  else
    @error = "Login failed, please try again"
    haml :login
  end
end

post '/add/:user' do
  add_a_todo
end

def add_a_todo
  if valid_user?
    r = @@redis
    userid = session[:user]
    pendkey = pending_key(userid)
    todo_id = r.incr todocount_key()
    r.sadd pendkey, todo_id # add the new id to list
    r.set todobody_key(todo_id), params[:body]
    r.set todostart_key(todo_id), DateTime.parse(params[:start]).to_s
    r.set todorecur_key(todo_id), params[:recur].blank? ? 0 : DateTime.parse(params[:recur])
    @message = "To do added"
    redirect "/#{userid}-#{r.get basename_key(userid)}"
  else
    redirect "/login"
  end
end

# My useful methods
helpers do
  def partial(page, options={})
    name = ("_" + page.to_s).to_sym
    haml name, options.merge!(:layout => false)
  end
end

class String
  def blank?
    nil? || empty?
  end
end

private

def valid_user?
  session[:user] and (session[:user] == params[:user].to_i.to_s)
end
=end

end
