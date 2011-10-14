class Todo
  include ActiveModel::Validations
  include ActiveModel::Conversion
   
  attr_accessor :description, :start_time
  validates_presence_of :description, :start_time
  
  def initialize(attr = {})
    attr.each do |attr_name, value|
      # construct method name from variable content
      send("#{attr_name}=", value)
    end
  end
 
  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end
  
  def add_a_todo
    if valid_user?
      r = @@redis
      userid = session[:user]
      pendkey = pending_key(userid)
      todo_id = r.incr todocount_key()
      r.sadd pendkey, todo_id # add the new id to list
      r.set todobody_key(todo_id), params[:body]
      r.set todostart_key(todo_id), DateTime.parse(params[:start]).to_s
      r.set todorecur_key(todo_id), params[:recur].blank? ? 0 : DateTime.parse(params[:recur])
      @message = "To do added"
      redirect "/#{userid}-#{r.get basename_key(userid)}"
    else
      redirect "/login"
    end
  end
  
end
