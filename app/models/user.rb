require 'bcrypt'

class User < Ohm::Model
  include ::BCrypt

  # attributes saved in redis
  attribute :passhash # hashed password
  reference :userhash, Userhash
  index :passhash
  
  # add attributes to validate but not save
  attr_accessor :password, :repeat

  def initialize(attrs={})
    params = attrs.clone
    if (params[:password] && params[:userhash])
      params[:passhash] = Password.create(params[:password])
    end
    super(params)
    self.password = params.delete(:password)
    self.repeat = params.delete(:repeat)
  end

  def validate
    assert_present :passhash
    assert_present :password
    assert_present :repeat
    # This passhash must not exist for the same
    # userhash
    #  puts "Got userhash = " + self.userhash.inspect
    errors << [[:passhash], [:not_unique]] if
      self.userhash.users.detect do |user|
        Password.new(user.passhash) == self.password
      end

    errors << [[:password], [:not_matching]] unless
      password == repeat
  end

  def save
    super
    self.userhash.users.add(self)
  end
  
  class << self # class methods
    def find_by_login(params)
      # first find the username
      uh = Userhash.find(params).first
      # Need to iterate over all passwords for this username
      uh.users.detect do |user|
        BCrypt::Password.new(user.passhash) == params[:password]
      end
    end
  end
end