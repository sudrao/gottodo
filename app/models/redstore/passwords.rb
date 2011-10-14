module Redstore
  module Crypto
    require 'digest/sha2'

    private

      def encrypt_username
        encrypt(username)
      end
      
      def encrypt_password
        encrypt(password)
      end

      def encrypt(string)
        secure_hash("#{salt}--#{string}")
      end

      def make_salt
        secure_hash("#{Time.now.utc}--#{password}")
      end

      def secure_hash(string)
        Digest::SHA2.hexdigest(string)
      end
    
  end
  
  module Saver
    include Crypto
    # We allow duplicate user names
    # But to distinguish them we create instances (numeric)
    # We store all such instances in a set.
    # Method returns the id assigned to the user
    # We don't store clear text usernames or passwords
    def add_user
      r = $redis
      instance = 0
      hashname = encrypt_username
      pass = encrypt_password
      key = userlist_key(hashname)
      if(r.exists(key))
        # make sure the same username + password wasn't used
        r.smembers(key).each do |inst|
          if pass == r.get(userpass_key(hashname, inst))
            return nil # sorry, exists
          end
        end
        instance = r.scard(key) # get number of instances
      end
      r.sadd(key, instance.to_s)
      userid = r.incr(Redstore::Keymap.usercount_key) # get a new id
      r.set userinst_key(userid), instance.to_s
      r.set username_key(userid), hashname
      r.set userid_key(hashname, instance.to_s), userid
      r.set userpass_key(hashname, instance.to_s), pass
      r.set usersalt_key(userid), salt
      return userid
    end  
  end

  require File.dirname(__FILE__) + '/keymap'
  module Auth
    extend Crypto
    extend Redstore::Keymap
    def self.authenticate(username, password)
      r = $redis
      hashname = secure_hash(username)
      pass = secure_hash(password)
      key = userlist_key(hashname)
      userid = nil
      if r.exists(key)
        r.smembers(key).each do |inst|
          if (pass == r.get(userpass_key(hashname, inst)))
            userid = r.get(userid_key(hashname, inst))
            break
          end
        end
      end
#      puts userid.inspect
      userid
    end
  end
end

#puts secure_hash("MyPass")
#puts secure_hash("")
#puts secure_hash("HisPass")
#puts secure_hash("MyPass")

