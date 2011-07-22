require 'sinatra'
require 'erb'
require 'redis'
require 'json'
require 'passwords'
require 'keymap'

# cloudfoundry stuff
configure do
  enable :sessions

  if vcap = ENV['VCAP_SERVICES']
    services = JSON.parse(vcap)
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    @@redis = Redis.new redis_conf
  else
    @@redis = Redis.new
  end
end

get '/hi' do
  "Hi! This is a to do's manager."
end

get '/' do
  erb :welcome
end

get '/login' do
  erb :login
end

post '/adduser'
end

get '/:user' do
  if valid_user?
    r = @@redis
    @userid = session[:user]
    @username = r.get username_key(@userid)
    @pending = r.smembers pending_key(@userid)
    @complete = r.smembers complete_key(@userid)
    erb :index
  else
    erb :login
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
    erb :login
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

def valid_user?
  session[:user] and (session[:user] == params[:user].to_i.to_s)
end
