require 'spec_helper.rb'
require 'yaml'
CREDENTIALS_FILE = Rails.root.join('config', 'oauth_web.yml')
require ::Rails.root.join('lib', 'evernote_api.rb')
EVERNOTE_LOGIN_URL = '/Login.action'
EVERNOTE_USER = 'sudtest1'
DUMMY_CALLBACK = "http://dummy.callback.url/"
SAVED_AUTH_FILE = Rails.root.join('tmp', 'oauth_test.yml')
NOTESTORE_PATH = "/edam/note/"

describe EvernoteAPI do
  before(:all) do
    @credentials = YAML::load_file(CREDENTIALS_FILE);
    File.open(SAVED_AUTH_FILE, "wt") { }
  end

  def request(req_token=nil)
    EvernoteAPI::Request.new(@credentials['evernote'], DUMMY_CALLBACK, req_token)
  end
  
  def access(access_token)
    EvernoteAPI::Access.new(@credentials['evernote'], access_token)
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
    File.open(SAVED_AUTH_FILE, 'wt') do |f|
      f.puts "#{user}:"
      f.puts "  token:"
      f.puts "    token: #{token}"
      f.puts "    secret: #{secret}"
      f.puts "  verifier: #{verifier}"
    end
  end
  
  def get_access
    oauth_yaml = YAML::load_file(SAVED_AUTH_FILE)
    oauth = oauth_yaml[EVERNOTE_USER]
    # return access token and shard id (scraped from token)
    return oauth['token']['token'], oauth['token']['token'].sub(/.*S=(.*?):.*/, '\1')
  end
    
  def verify_access
    oauth_yaml = YAML::load_file(SAVED_AUTH_FILE)
    oauth = oauth_yaml[EVERNOTE_USER]
    req = request(oauth['token'])
    req.verify(oauth['verifier'])
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
    # Save temp oauth credentials for this user in a file
    save_oauth(EVERNOTE_USER, token.token, token.secret, oauth_verifier)
  end

  it "verifies access", :verifier => true do
    access = verify_access()
    access.should_not be_nil
    access.token.should_not be_nil
    access.secret.should_not be_nil
    # Save final oauth credentials for this user
    save_oauth(EVERNOTE_USER, access.token, access.secret, "")
  end


  it "can access an account" do
    token, shard_id = get_access
    token.should_not be_nil
    
    note_store_url = @credentials['evernote']['options']['site'] + NOTESTORE_PATH + shard_id
    # note_store_url.should == nil
    note_store = Evernote::NoteStore.new(note_store_url)
    note_store.should_not be_nil
    notebooks = note_store.listNotebooks(token)
    notebooks.should_not be_nil
  end
  
  def access_notestore
    token, shard_id = get_access
    note_store_url = @credentials['evernote']['options']['site'] + NOTESTORE_PATH + shard_id
    return Evernote::NoteStore.new(note_store_url), token
  end
  it "can access notes" do
    note_store, token = access_notestore
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(:words => '*')
    note = note_store.findNotes(token, filter, offset=0, maxNotes=1).notes.first
    note.should_not be_nil     
  end
  
  it "can access a todo marked note" do
    note_store, token = access_notestore
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(:words => 'todo:*')
    note = note_store.findNotes(token, filter, offset=0, maxNotes=1).notes.first
    note.should_not be_nil 
  end
end
