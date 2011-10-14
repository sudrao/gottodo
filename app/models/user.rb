require 'redstore/passwords'
#require 'redstore/keymap'

class User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include Redstore::Keymap
  include Redstore::Saver
  IS_NEW = true

  @@usercount = $redis.get(Redstore::Keymap.usercount_key) # read initial value here

  attr_accessor :username, :password, :repeat, :salt
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

  def save(is_new=false)
    make_salt if is_new
    id = add_user
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
      u.save(IS_NEW)
      u
    end

    def find_by_login(params)
      id = Redstore::Auth.authenticate(params[:username], params[:password])
      if id
        params[:repeat] = params[:password]
        params[:salt] = $redis.get usersalt_key(id)
        u = self.new(params, id)
      end
      u
    end

    def find(id)
      # verify the id exists. Get unencrypted fields
      salt_val = $redis.get usersalt_key(id)
      if (salt_val)
        params[:salt] = salt_val
        params[:password] = params[:repeat] = "dummy" # keep validator happy
        u = self.new(params, id)
      end
      u
    end
  end
end