require 'spec_helper'

describe Todo do
  before(:each) do
    @params = { body: "Physical checkup", start: "2011-10-5 9:00", recur: "" }
    @userid = 1
  end
  
  it "saves a valid todo" do
    Todo.create(@params, @userid).should have(:no).errors
  end
  
  it "finds a todo" do
    t = Todo.create(@params, @userid)
    id = t.todo_id
    tt = Todo.find(id)
    tt.body.should == @params[:body]
  end
end
