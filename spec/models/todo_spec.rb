require 'spec_helper'

describe Todo do
  before(:all) do
    Todo.create_indexes
  end
  before(:each) do
    @params = { user_id: 1, title: "Physical checkup", start: DateTime.parse("2011-10-5 9:00"), recur: 0 }
  end
  
  it "saves a valid todo" do
    t = Todo.new(@params)
    
    t.valid?.should be_true
    t.should have(:no).errors
    t.save.should be_true
  end
  
  it "cleans up the db for each example" do
    Todo.count.should == 0
  end
  
  it "finds a todo" do
    t = Todo.create(@params)
    id = t.id
    tt = Todo.find(id)
    tt.title.should == @params[:title]
  end
  
  it "saves more than one todo" do
    Todo.create(@params)
    @params[:title] = "Moral Checkup"
    Todo.create(@params)
    Todo.count.should == 2
  end
  
  it "prevents duplicate todos" do
    Todo.create(@params)
    Todo.create(@params).should have(1).error
  end
end
