require './redis_key_smith'
class RKSTest
  extend RedisKeySmith
  
  self.rks_instance_make('user_name_key' => 2, :full_name => 3, :how => 1, 'how_did_we_get_here' => 2)
  self.rks_instance_make('user_name_build', 'how_did_we_get_there', 'more')
  
  self.rks_class_make('user_name_key' => 2, :full_name => 3, :how => 1, 'how_did_we_get_here' => 2)
  self.rks_class_make('user_name_build', 'how_did_we_get_there', 'more')
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

end
