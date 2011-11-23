require 'bcrypt'
# We need a fixed salt for the app instance which ideally
# should be generated once and saved in the database. Just one salt
# value to be used for hashing the username. Defining that as a constant
# here. Change to a db value later so each installation gets a different salt.
FIXED_SALT = "$2a$10$6vpBC/mj.2Xi5zz/fxuidu"

# Each entry in the set points to one unique user. Multiple users are allowed to have
# the same username, so the hashed value will also be the same for them. The distinction is
# the password used, which must differ if the username is duplicate.
class Userhash < Ohm::Model
  include ::BCrypt
  # We run bcrypt hash on username with fixed salt and use that as the key to Userhash.
  # Variable salt per username would require a full search of the db.
  # Passwords have a unique salt per password.
  attribute :hashname
  collection :users, User
  
  index :hashname
  
  # The parameter that comes in is a username
  # and gets hashed but not saved.
  def initialize(params={})
    if params[:username]
      hash = BCrypt::Engine.hash_secret(params[:username], Userhash.username_salt)
      params[:hashname] = Password.new(hash)
      params.delete(:username)
    end
    super(params)
  end
  
  def validate
    assert_present :hashname
    assert_unique :hashname
  end
  
  def self.username_salt
    FIXED_SALT
  end
  # def self.find_by_username(name)
  #   find(:hashname => encrypt_username(name))
  # end
end
