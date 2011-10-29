require File.expand_path(File.dirname(__FILE__) + "/../spec/spec_helper.rb")
require 'yaml'
CREDENTIALS_FILE = Rails.root.join('config', 'oauth_web.yml')
require ::Rails.root.join('lib', 'evernote_api.rb')
EVERNOTE_LOGIN_URL = '/Login.action'
EVERNOTE_USER = 'sudtest1'
DUMMY_CALLBACK = "http://dummy.callback.url/"
SAVED_AUTH_FILE = Rails.root.join('tmp', 'oauth_test.yml')

describe EvernoteAPI do
  before(:all) do
    @credentials = YAML::load_file(CREDENTIALS_FILE);
    File.open(SAVED_AUTH_FILE, "wt") { }
  end

  def request(req_token=nil)
    EvernoteAPI::Request.new(@credentials['evernote'], DUMMY_CALLBACK, req_token)
  end

  def connect(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def get_cookies(str, cookies={})
    return cookies unless str
    assigns = str.split(/[;,]/)
    assigns.each do |a|
      # skip attributes
      next if a[/(Domain|Path|Expire|Secure|HttpOnly|Max-Age|Version|deleteme)/i]
      cookies[a[/[^ =]+/]] = a[/=([^ ]+)/, 1] unless a.blank?
    end
    cookies
  end

  def cookies_to_s(cookies)
    str = ''
    cookies.each do |k, v|
      str << "#{k}=#{v}; "
    end
    str
  end

  def get_form(body, name)
    n = Nokogiri::HTML::DocumentFragment.parse(body)
    nform = n.xpath('.//form', {'name' => name})
    #puts nform.inspect
    form = {}
    # Get attributes of form
    nform.each { |node| node.attributes.each { |k, a| form[k] = a.value } }
    # Get form parameters
    params = {}
    nform.xpath('.//input').each do |field|
      params[field['name']] = field['value']
    end
    form['params'] = params
    #puts form.inspect
    form
  end

  def save_oauth(user, token, secret, verifier)
    File.open(SAVED_AUTH_FILE, 'at') do |f|
      f.puts "#{user}:"
      f.puts "  token:"
      f.puts "    token: #{token}"
      f.puts "    secret: #{secret}"
      f.puts "  verifier: #{verifier}"
    end
  end
  
  it "gets authorization url" do
    req = request()
    req.should_not be_nil
    link = req.authorize_url
    link.should =~ /.*oauth_token=.*/
  end

  it "authorizes and gets verifier" do
    req = request()
    link = req.authorize_url
    token = req.request_token
    # puts link
    auth_uri = URI.parse(link)
    http = connect(auth_uri)
    # Go to the uri to get redirect to login page
    response = http.get(auth_uri.request_uri)
    response.code.should == '302'
    uri = URI.parse(response['location'])
    response = http.get(uri.request_uri)
    response.code.should == '200'
    cookies = get_cookies(response['set-cookie'])
    # uri.request_uri.should == "hello"
    # log in as Evernote user and get the cookies
    post_request = Net::HTTP::Post.new(uri.request_uri[/\A[^?]+/])
    post_request.set_form_data({
      'username' => EVERNOTE_USER, 'password' => @credentials['password'], 'remember' => 'true',
      'login' => 'Sign in', 'targetUrl' => auth_uri.request_uri
    })
    post_request['Cookie'] = cookies_to_s(cookies) if cookies != {}
    # http.set_debug_output($stderr)
    response = http.request(post_request)
    response.code.should == '302'
    get_cookies(response['set-cookie'], cookies)
    cookies_to_s(cookies).should =~ /.*SESSION.*/
    uri = URI.parse(response['location'])
    # Load the authorize page and get other cookies
    get_request = Net::HTTP::Get.new(uri.request_uri)
    get_request['Cookie'] = cookies_to_s(cookies)
    response = http.request(get_request)
    response.code.should == '200'
    get_cookies(response['set-cookie'], cookies)
    # Parse the form for next step
    form = get_form(response.body, 'oauth_authorize_form')
    # Authorize
    post_request = Net::HTTP::Post.new(form['action'])
    params = form['params']
    params.delete('cancel') # leave 'authorize' in there
    post_request.set_form_data(params)
    post_request['Cookie'] = cookies_to_s(cookies)
    # http.set_debug_output($stderr)
    response = http.request(post_request)

    response.code.should == '302'
    location = response['location']
    location.should =~ /#{DUMMY_CALLBACK}.*/
    # Get verifier
    oauth_verifier = location[/oauth_verifier=(.+?)(\z|&)/, 1]
    oauth_verifier.should_not be_nil
    oauth_token = location[/oauth_token=(.+?)(\z|&)/, 1]
    oauth_token.should == token.token
    # Save oauth for this user in a file
    save_oauth(EVERNOTE_USER, token.token, token.secret, oauth_verifier)
  end

  it "verifies access" do
    oauth_yaml = YAML::load_file(SAVED_AUTH_FILE)
    oauth = oauth_yaml[EVERNOTE_USER]
    req = request(oauth['token'])
    @access = req.verify(oauth['verifier'])
    @access.should_not be_nil
    @access.token.should_not be_nil
    @access.secret.should_not be_nil
  end


  # it "can access an account" do
  #   # Recreate consumer and request token that was used in new action
  #   req = TwitterAPI::Request.new(credentials, session[:rtoken], session[:rsecret])
  # 
  # end
end
=begin
  @twitter = true
  begin
    credentials = TwitterAPI::Base.get_yaml_credentials
    req = TwitterAPI::Request.new(credentials)
    @link = req.authorize_url
    # Save request token essentials to use during create
    session[:rtoken] = req.request_token.token
    session[:rsecret] = req.request_token.secret
    render :template => "yammers/new.html.erb"
  rescue
    flash[:error] = $!
    render :template => "yammers/show.html.erb"
  end
end

# POST /twitter
# Create and save new credentials for this user
def create
  @twitter = true
  begin
    credentials = TwitterAPI::Base.get_yaml_credentials
    # Recreate consumer and request token that was used in new action
    req = TwitterAPI::Request.new(credentials, session[:rtoken], session[:rsecret])
    # Now verify with Twitter and get the final access token for user
    @result = "Congratulations - cross-posting with Twitter is now set up!"
    begin
      access_token = req.verify(params[:verifier])
      # save for next time
      @visitor_home.twitter_token = access_token.token
      @visitor_home.twitter_secret = access_token.secret
      @visitor_home.twitter_name = params[:twitter_name]
      if @visitor_home.save
        redirect_to :action => 'show'
      else
        @result = "ublog login or database error - Twitter setup failed."
        render :template => "yammers/create.html.erb"
      end
    rescue
      @result = "Twitter authorization failed! Your verification code was not accepted: " + $!
      render :template => "yammers/create.html.erb"
    end
  rescue
    flash[:error] = $!
    @result = "We're sorry but something went wrong."
    render :template => "yammers/create.html.erb"
  end
end

# DELETE /twitter
# Remove credentials
def destroy
  @visitor_home.update_attributes(:twitter_name => nil, :twitter_token => nil, :twitter_secret => nil)
  redirect_to :action => 'show'
end
end
=end
