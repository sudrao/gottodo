require 'redstore/passwords'
class User < Ohm::Model
  include Redstore::Saver

  # attributes saved in redis
  attribute :passhash # hashed password
  collection :userhashes, Userhash # we should not need this reverse reference
  
  # attributes not saved in redis
  attr_accessor :username, :password, :repeat
  
  # validates_presence_of :username, :password, :repeat, :only => :create
  # validates :username, :length => { :in => 4..20 }, :only => :create
  # validates :password, :length => { :in => 4..80 }, :only => :create
  # validate :must_repeat_password, :only => :create

  def must_repeat_password
    errors.add(:password, "The entered passwords are not the same.") unless
      username == repeat
  end

  # Save a new user record. Since we don't save the username
  # in the clear but need to have that field for other things
  # this method cannnot be called to update a user record.
  def save
    make_or_get_salt # salt is per username but usernames are not unique
    id = add_user # id is unique (one per username+password combination)
    if id
      @@usercount = id.to_i
      @userid = id
    else
      errors.add(:username, "Already exists")
      return nil
    end
    self
  end


  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end

  class << self # class methods like ActiveRecord
    def create(params)
      u = self.new(params)
      #      puts u.inspect
      u.save
      u
    end

    def find_by_login(params)
      id, salt = Redstore::Auth.authenticate(params[:username], params[:password])
      if id
        params[:salt] = salt
        u = self.new(params, id)
      end
      u
    end

    def authenticate_with_salt(userid, salt)
      if salt == Redstore::Auth.get_salt_by_id(userid)
        u = self.new({:salt => salt}, userid)
      end
      u
    end
    
    def find(id)
      # verify the id exists. Get encrypted fields
      r = $redis
      hashname = r.get username_key(id)
      salt = r.get Redstore::Auth.usersalt_key(hashname)
      params = {salt: salt}
      u = self.new(params, id)
    end
  end
end