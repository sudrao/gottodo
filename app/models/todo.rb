class Todo
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include Redstore::Keymap
  include Redstore::Saver

  attr_accessor :body, :start, :recur
  attr_reader :userid, :todo_id
  validates_presence_of :body, :start, :recur

  def initialize(attr = {}, userid=nil, id=nil)
    attr.each do |attr_name, value|
      value = DateTime.parse(value) if attr_name == :start
      # construct method name from variable content
      send("#{attr_name}=", value)
    end
    @userid = userid
    @todo_id = id
  end

  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end

  def save
    @todo_id = add_todo
  end
  
  class <<self
    def create(params, userid)
      t = self.new(params, userid)
      #      puts t.inspect
      t.save
      t
    end
    
    def find(todo_id)
      r = $redis
      body = r.get Redstore::Keymap.todobody_key(todo_id)
      start = r.get Redstore::Keymap.todostart_key(todo_id)
      recur = r.get Redstore::Keymap.todorecur_key(todo_id)
      userid = r.get Redstore::Keymap.todouser_key(todo_id)
      # TODO Should have used JSON
      self.new({body: body, start: start, recur: recur}, userid, todo_id)
    end
  end
end

