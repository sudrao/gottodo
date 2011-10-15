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
    errors.add(:password, "The entered passwords are not the same.") unless
    username == repeat
  end

  def usercount
    @@usercount
  end

  def save(is_new=false)
    if is_new
      make_salt
      id = add_user
      if id
        @@usercount = id.to_i
        @userid = id
      else
        errors.add(:username, "Already exists")
      end
    else
      # at this time there are no attributes that can change
    end
    @userid
  end


  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end

  class << self # class methods like ActiveRecord
    def create(params)
      u = self.new(params)
#      puts u.inspect
      u.save(IS_NEW)
      u
    end

    def find_by_login(params)
      id, salt = Redstore::Auth.authenticate(params[:username], params[:password])
      if id
        params[:repeat] = params[:password]
        params[:salt] = salt
        u = self.new(params, id)
      end
      u
    end

    def find(id)
      # verify the id exists. Get encrypted fields
      r = $redis
      hashname = r.get username_key(id)
      salt = r.get usersalt_key(hashname)
      params = {salt: salt}
      u = self.new(params, id)
    end
  end
end