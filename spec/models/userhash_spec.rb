require 'spec_helper'

describe Userhash do
  before(:each) do
    @params = {:username => "test1"}
  end
  
  it "saves a valid userhash" do
    Userhash.create(@params).should have(:no).errors
  end
  
  it "validates username present" do
    uh = Userhash.new()
    uh.should_not be_valid
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

