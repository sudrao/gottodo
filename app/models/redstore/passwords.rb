module Redstore
  module Crypto
    require 'digest/sha2'
    @@fixed_salt = "f0c982f8e53f3ef08a52aa9af36aabfb335ac1bfc29d2ccb232606e364123d9a"

    def encrypt_username(name)
      # Salt is not available until we find the username
      # so use a fixed salt
      secure_hash("#{@@fixed_salt}--#{name}")
    end

    def encrypt_password
      encrypt(self.password)
    end

    def encrypt(string, salt)
      secure_hash("#{salt}--#{string}")
    end

    def encrypt_with_salt(string, salt)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}")
    end

    # def make_or_get_salt
    #   unless self.salt
    #     self.salt = Auth.get_salt(self.username)
    #     make_salt unless self.salt
    #   end
    # end
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
      userid = r.incr(usercount_key) # get a new id
      r.set userinst_key(userid), instance.to_s
      r.set username_key(userid), hashname
      r.set userid_key(hashname, instance.to_s), userid
      r.set userpass_key(hashname, instance.to_s), pass
      r.set usersalt_key(hashname), salt
      #      puts "username=#{username}, id=#{userid}, salt=#{salt}, pass=#{pass}"
      #      puts "Saved with userlist key=#{key}"
      return userid
    end  
    
    def add_todo
      r = $redis
      pendkey = pending_key(userid)
      todo_id = r.incr todocount_key() # get a new todo id
      r.sadd pendkey, todo_id # add the new id to list
      r.set todobody_key(todo_id), self.body
      r.set todostart_key(todo_id), self.start
      r.set todorecur_key(todo_id), self.recur
      r.set todouser_key(todo_id), self.userid
      todo_id
    end
  end

  require File.dirname(__FILE__) + '/keymap'
  module Auth
    extend Crypto
    extend ::RedisKeySmith
    
    rks_make_key :usersalt_key, :userlist_key, args: 1, class_method: true
    rks_make_key :userid_key, :userpass_key, args: 2, class_method: true
    
    def self.authenticate(username, password)
      r = $redis
      hashname = encrypt_username(username)
      key = userlist_key(hashname)
      #      puts "Searching for key=#{key}"
      userid = nil
      salt = nil
      if r.exists(key)
        # get the salt
        salt = r.get usersalt_key(hashname)
        pass = encrypt_with_salt(password, salt)
        r.smembers(key).each do |inst|
          if (pass == r.get(userpass_key(hashname, inst)))
            userid = r.get(userid_key(hashname, inst))
            break
          end
        end
      end
      # puts "Got id='#{userid}'"
      return userid, salt
    end

    def self.get_salt(username)
      hashname = encrypt_username(username)
      $redis.get usersalt_key(hashname) 
    end
    
    def self.get_salt_by_id(userid)
      r = $redis
      hashname = r.get username_key(userid)
      r.get usersalt_key(hashname)
    end
    
  end
end

  #puts secure_hash("MyPass")
  #puts secure_hash("")
  #puts secure_hash("HisPass")
  #puts secure_hash("MyPass")

