OAUTH_CREDENTIALS={
  :evernote=>{
    :key=>"",
    :secret=>"",
    :client=>:oauth_gem, # :twitter_gem or :oauth_gem (defaults to :twitter_gem)
    :expose => false, # expose client at /oauth_consumers/twitter/client see docs
    :allow_login => true # Use :allow_login => true to allow user to login to account
  }
}
OAUTH_CREDENTIALS = YAML::load_file('evernote_web.yml')
