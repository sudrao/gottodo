require 'redis_key_smith'
class RKSTest
  extend RedisKeySmith
  
  self.rks_make_key('user_name_key', 'how_did_we_get_here', :args => 2, :instance_method => true, :class_method => true)
  self.rks_make_key(:full_name, :args => 3)
  self.rks_make_key(:how, args: 1, instance_method: true)
  self.rks_make_key('user_name_build', 'how_did_we_get_there', 'more')
  
  self.rks_make_key(:full_name, :args => 3, :class_method => true)
  self.rks_make_key(:how, :args => 1, :class_method => true)
  self.rks_make_key('user_name_build', 'how_did_we_get_there', 'more', :class_method => true)
end

describe "Redis Key Smith" do
  before :all do
    @a = RKSTest.new
  end
  
  it "returns a string for instance methods" do
    @a.user_name_key(1, 3).should == "USER1::NAME3::KEY"
    @a.full_name(1, 2, 3).should == "FULL1::NAME2::3::"
    @a.how(1).should == "HOW1::"
    @a.how_did_we_get_here(2, 5).should == "HOW2::DID5::WE"
    @a.user_name_build.should == "USER::NAME::BUILD"
    @a.how_did_we_get_there.should == "HOW::DID::WE::GET::THERE"
    @a.more.should == "MORE"    
  end

  it "returns a string for class methods" do
    RKSTest.user_name_key(1, 3).should == "USER1::NAME3::KEY"
    RKSTest.full_name(1, 2, 3).should == "FULL1::NAME2::3::"
    RKSTest.how(1).should == "HOW1::"
    RKSTest.how_did_we_get_here(2, 5).should == "HOW2::DID5::WE"
    RKSTest.user_name_build.should == "USER::NAME::BUILD"
    RKSTest.how_did_we_get_there.should == "HOW::DID::WE::GET::THERE"
    RKSTest.more.should == "MORE"    
  end

  it "raises error if args don't match count of args" do
    lambda { @a.full_name(1, 2) }.should raise_error(ArgumentError)
    lambda { @a.full_name(1, 2, 3, 4) }.should raise_error(ArgumentError)
  end
end
