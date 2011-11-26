require 'bcrypt'
# We need a fixed salt for the app instance which is
# generated once and saved in the database.
USERNAME_SALT_KEY = "USERNAME_SALT"

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
      hash = Engine.hash_secret(params[:username], Userhash.username_salt)
      params[:hashname] = Password.new(hash)
      params.delete(:username)
    end
    super(params)
  end
  
  def validate
    assert_present :hashname
    assert_unique :hashname
  end
  
  class << self
    @username_salt = Ohm.redis.get USERNAME_SALT_KEY
    
    def username_salt
      unless @username_salt
        # if redis doesn't have the salt yet, generate salt
        Ohm.redis.set USERNAME_SALT_KEY, BCrypt::Engine.generate_salt
        @username_salt = Ohm.redis.get USERNAME_SALT_KEY
      end
      @username_salt
    end
  end
end
