require 'digest/md5'
require 'keymap'

def digest_of(pass)
  md5 = Digest::MD5::new("CR8TD89464789HJKI7212320K7423423jlUIUdf0") # secret
  md5.update(pass)
  md5.hexdigest
end

# We allow duplicate user names
# But to distinguish them we add a 1, 2, 3, ... suffix
# We store all such duplicates in a set.
# Method returns the realname and id assigned to the user
def add_user(username, password)
  r = @@redis
  realname = username
  key = userlist_key(username)
  pass = digest_of(password)
  if(r.exists?(key))
    # make sure the same username + password wasn't used
    r.smembers(key).each do |name|
      if pass == r.get(userpass_key(username, name))
        return nil, nil # sorry, exists
      end
    end
    n = r.scard(key) # get number of dupes
    realname << n.to_s
  end
  r.sadd(key, realname)
  userid = r.incr(usercount_key) # get a new id
  r.set username_key(userid), realname
  r.set basename_key(userid), username
  r.set userid_key(username, realname), userid
  r.set userpass_key(username, realname), pass
  return realname, userid
end  
      
def authenticate(username, password)
  r = @@redis
  key = userlist_key(username)
  pass = digest_of(password)
  if r.exists?(key)
    r.smembers(key).each do |name|
      if (pass == r.get(userpass_key(username, name))
        userid = r.get(userid_key(username, name))
        realname = name
        break
      end
    end
  end
  return realname, userid
end

puts digest_of("MyPass")
puts digest_of("")
puts digest_of("HisPass")
puts digest_of("MyPass")

