require 'spec_helper'

describe User do
  before(:each) do
    @userhash = Userhash.create(:username => "test1")
    puts "userhash=" + @userhash.inspect
    @params = {:userhash => @userhash, :password => "secret1", :repeat => "secret1"}
  end
  
  it "saves a valid user" do
    User.create(@params).should have(:no).errors
  end
  
  it "saves a valid user and finds it in the userhash set" do
    u = User.create(@params)
    u.userhash.should_not be_nil
    Userhash[1].should_not be_nil
    Userhash[1].inspect.should be_nil
  end
  
  it "finds a valid user", :one => true do
    User.create(@params)
    User.find_by_login(@params).should_not be(nil)
  end
  
  it "fails to create duplicate user" do
    User.create(@params)
    User.create(@params).should have(1).error
  end
  
  it "can create two users with same username (password different)" do
    User.create(@params)
    other = @params.clone
    other[:password] = "secret_other"
    User.create(other).should have(:no).errors
    User.find_by_login(@params).should_not be(nil)
  end
end
