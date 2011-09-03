require 'redstore/passwords'
#require 'redstore/keymap'

class User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include Redstore::Keymap
  include Redstore::Saver
  
  @@usercount = $redis.get(Redstore::Keymap.usercount_key) # read initial value here
  
  attr_accessor :username, :password, :repeat
  validates_presence_of :username, :password, :repeat
  validates :username, :length => { :in => 4..20 }
  validates :password, :length => { :in => 4..80 }
  validate :must_repeat_password
    
  def initialize(attr = {}, id=nil)
    attr.each do |attr_name, value|
      # construct method name from variable content
      send("#{attr_name}=", value)
    end
    @userid = id
  end
  
  def must_repeat_password
    errors.add("The entered passwords are not the same.") unless
      username == repeat
  end
  
  def usercount
    @@usercount
  end
  
  def save
    id = add_user(@username, @password)
    if id
      @@usercount = id.to_i
      @userid = id
    end
    id
  end
  
  
  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end

  class << self # class methods like ActiveRecord
    def create(params)
      u = self.new(params)
      u.save
      u
    end
    
    def find_by_login(params)
      id = Redstore::Auth.authenticate(params[:username], params[:password])
      if id
        params[:repeat] = params[:password]
        u = self.new(params, id)
      end
      u
    end
  end
end