require 'spec_helper'

describe User do
  before(:each) do
    @params = {:username => "test1", :password => "secret1", :repeat => "secret1"}
  end
  
  it "saves a valid user" do
    User.create(@params).should have(:no).errors
  end
  
  it "finds a valid user" do
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
