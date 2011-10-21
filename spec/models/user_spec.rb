require 'spec_helper'

describe User do
  before(:each) do
    @userhash = Userhash.create(:username => "test1")
#    puts "userhash=" + @userhash.inspect
    @params = {:userhash => @userhash, :password => "secret1", :repeat => "secret1"}
    @login = {:username => "test1", :password => "secret1"}
  end
  
  it "saves a valid user" do
    User.create(@params).should have(:no).errors
  end
  
  it "saves a valid user and finds it in the userhash set" do
    u = User.create(@params)
    u.userhash.should_not be_nil
    Userhash[1].should == u.userhash
    u.userhash.users.all[0].should == u
  end
  
  it "finds a valid user", :one => true do
    u = User.create(@params)
    User.find_by_login(@login).should == u
  end
  
  it "fails to create duplicate user" do
    User.create(@params)
    User.create(@params).should have(1).error
  end
  
  it "can create two users with same username (password different)" do
    u1 = User.create(@params)
    other = @params.clone
    other[:password] = "secret_other"
    other[:repeat] = other[:password]
    u2 = User.create(other)
    User.find_by_login(@login).should == u1
    other[:username] = @login[:username]
    User.find_by_login(other).should == u2
  end
end
