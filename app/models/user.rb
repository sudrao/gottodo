require 'redstore/passwords'
class User < Ohm::Model
  extend Redstore::Crypto
  include Redstore::Saver

  # attributes saved in redis
  attribute :passhash # hashed password
  reference :userhash, Userhash
  index :passhash
  
  # add attributes to validate but not save
  attr_accessor :password, :repeat

  def initialize(params={})
    new_params = params.clone
    if (params[:password] && params[:userhash])
      passhash = User.encrypt(params[:password], params[:userhash].salt)
      new_params[:passhash] = passhash
    end
    super(new_params)
  end

  def validate
    assert_present :passhash
    assert_present :password
    assert_present :repeat
    # This passhash must not exist for the same
    # userhash
   #  puts "Got userhash = " + self.userhash.inspect
    # self.userhash.users.each do |user|
    #   if user.passhash == self.passhash
    #     errors << [[:passhash], [:not_unique]] 
    #     break;
    #   end
    # end
    errors << [[:password], [:not_matching]] unless
    password == repeat
  end

  def save
    super
    self.userhash << self
  end
  
  class << self # class methods like ActiveRecord
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
  end
end