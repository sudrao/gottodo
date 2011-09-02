module Redstore
  module Crypto
    require 'digest/md5'

    def digest_of(pass)
      md5 = Digest::MD5::new
      md5.update("CR8TD89464789HJKI7212320K7423423jlUIUdf0") # secret
      md5.update(pass)
      md5.hexdigest
    end
  end
  
  module Saver
    include Crypto
    # We allow duplicate user names
    # But to distinguish them we create instances (numeric)
    # We store all such instances in a set.
    # Method returns the id assigned to the user
    # We don't store clear text usernames or passwords
    def add_user(username, password)
      r = $redis
      instance = 0
      hashname = digest_of(username)
      pass = digest_of(password)
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
      return userid
    end  
  end

  require File.dirname(__FILE__) + '/keymap'
  module Auth
    extend Crypto
    extend Redstore::Keymap
    def self.authenticate(username, password)
      r = $redis
      hashname = digest_of(username)
      pass = digest_of(password)
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

#puts digest_of("MyPass")
#puts digest_of("")
#puts digest_of("HisPass")
#puts digest_of("MyPass")

