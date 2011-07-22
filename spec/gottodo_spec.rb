require File.dirname(__FILE__) + '/spec_helper'

describe "gottodo" do
  include Rack::Test::Methods
  
  def app
    @app ||= Sinatra::Application
  end
  
  it "should respond to /" do
    get '/'
    last_response.should be_ok
    last_response.body.should =~ /Log in/
    last_response.body.should_not =~ /FAILED/
  end
  
  it "should create a user" do
    post '/adduser', :user => "myysername", :password => "mypassword", :repeat => "mypassword"
    last_response.should be_ok
    last_response.body.should_not =~ /FAILED/
    last_response.body.should =~ /Congratulations/
  end
  
  it "should fail bad usename or password" do
    post '/adduser', :user => "myy", :password => "mypassword", :repeat => "mypassword"
    last_response.should be_ok
    last_response.body.should =~ /FAILED/
  end
  
end
