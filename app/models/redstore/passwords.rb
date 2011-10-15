module Redstore
  module Crypto
    require 'digest/sha2'

    private

      def encrypt_username(name)
        # Salt is not available until we find the username
        # so use a fixed salt
        fixed_salt = "f0c982f8e53f3ef08a52aa9af36aabfb335ac1bfc29d2ccb232606e364123d9a"
        secure_hash("#{fixed_salt}--#{name}")
      end
      
      def encrypt_password
        encrypt(self.password)
      end

      def encrypt(string)
        secure_hash("#{self.salt}--#{string}")
      end

      def encrypt_with_salt(string, salt)
        secure_hash("#{salt}--#{string}")
      end

      def make_salt
        self.salt ||= secure_hash("#{Time.now.utc}--#{password}")
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
      hashname = encrypt_username(self.username)
      pass = encrypt_password
      key = userlist_key(hashname)
      if(r.exists(key))
        # make sure the same username + password wasn't used
#        puts "Entry exists while adding"
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
      r.set usersalt_key(hashname), salt
#      puts "username=#{username}, id=#{userid}, salt=#{salt}, pass=#{pass}"
#      puts "Saved with userlist key=#{key}"
      return userid
    end  
  end

  require File.dirname(__FILE__) + '/keymap'
  module Auth
    extend Crypto
    extend Redstore::Keymap
    def self.authenticate(username, password)
      r = $redis
      hashname = encrypt_username(username)
      key = userlist_key(hashname)
#      puts "Searching for key=#{key}"
      userid = nil
      salt = nil
      if r.exists(key)
#        puts "hey found a matching username"
        # get the salt
        salt = r.get usersalt_key(hashname)
        pass = encrypt_with_salt(password, salt)
        r.smembers(key).each do |inst|
          if (pass == r.get(userpass_key(hashname, inst)))
#            puts "Match found for password"
            userid = r.get(userid_key(hashname, inst))
            break
          end
        end
      end
#      puts "Got id='#{userid}'"
      return userid, salt
    end
  end
end

#puts secure_hash("MyPass")
#puts secure_hash("")
#puts secure_hash("HisPass")
#puts secure_hash("MyPass")

