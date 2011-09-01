require 'redstore/passwords'
require 'redstore/keymap'

class User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend Redstore::Keymap
  include Redstore::Passwords
  
  @@usercount = $redis.get(usercount_key) # read initial value here
  
  attr_accessor :username, :password, :repeat
  validates_presence_of :username, :password, :repeat
  validates :username, :length => { :in => 4..20 }
  validates :password, :length => { :in => 4..80 }
  validate :must_repeat_password
    
  def initialize(attr = {})
    attr.each do |attr_name, value|
      # construct method name from variable content
      send("#{attr_name}", value)
    end
  end
  
  def must_repeat_password
    errors.add("The entered passwords are not the same.") unless
      username == repeat
  end
  
  def usercount
    @@usercount
  end
  
  def save
    add_user(username, password)
  end

  # This method allows use of url helpers without a standard db
  def persisted?
    false
  end
end