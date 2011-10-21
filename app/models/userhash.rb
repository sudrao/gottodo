# SHA1 hash of username, i.e. encrypted username is saved as top level set in Redis
# Each entry in the set points to one unique user. Multiple users are allowed to have
# the same username, so the hashed value will also be the same for them. The distinction is
# the password used, which must differ if the username is duplicate.
class Userhash < Ohm::Model
  extend Redstore::Crypto
  # We run SHA1 hash on username with fixed salt and use that as the key to Userhash.
  # This yields a salt to be used for hashing user passwords. Passwords are per user
  # and saved as part of the User model but we need the salt to match passwords and
  # find a user, so the password's salt is per userhash.
  attribute :hashname
  attribute :salt
  set :users, User
  
  index :hashname
  
  # The parameter that comes in is a username
  # and gets hashed but not saved.
  def initialize(params={})
    salt = Userhash.make_salt 
    new_params = {:salt => salt}
    if params[:username]
      hashname = Userhash.encrypt_username(params[:username])
      new_params[:hashname] = hashname
    end
    super(new_params)
  end
  
  def validate
    assert_present :hashname, :salt
    assert_unique :hashname
  end
  
  def self.find_by_username(name)
    find(:hashname => encrypt_username(name))
  end
end
