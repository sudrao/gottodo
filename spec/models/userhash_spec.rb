require 'spec_helper'

describe Userhash do
  before(:each) do
    @params = {:username => "test1"}
  end
  
  it "saves a valid userhash" do
    Userhash.create(@params).should have(:no).errors
  end
  
  it "saves and finds a userhash" do
    uh = Userhash.create(@params)
    uh.id.should == "1"
    Userhash['1'].salt.should == uh.salt
    Userhash['1'].hashname.should == uh.hashname    
  end
  
  it "validates username present" do
    uh = Userhash.new()
    uh.should_not be_valid
    uh.errors.should == [[:hashname, :not_present], [:salt, :not_present]]
  end
  
  it "fails to save duplicate" do
    Userhash.create(@params).should have(:no).errors
    uh = Userhash.new(@params)
    uh.should_not be_valid
    errors = uh.errors
    errors[0][0].should == :hashname
    errors[0][1].should == :not_unique
  end
  
  it "saves 2 records" do
    Userhash.create(@params).should have(:no).errors
    @params[:username] = "test2"
    Userhash.create(@params).should have(:no).errors
  end
end

