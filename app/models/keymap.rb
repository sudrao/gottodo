def usercount_key
  # Global count of users
  # Does not decrement even if user removed
  "USER::USERCOUNT"
end

def todocount_key
  # Global count of todos
  # Does not decrement even if todo removed
  "TODO::TODOCOUNT"
end

def userlist_key(hashname)
  # Set of possibly duplicate names
  # distinguished by numeric extension
  "USER:#{hashname}:USERLIST"
end

# only username+realname is guaranteed to be unique
def userid_key(hashname, instance)
  "USER:{hashname}:{instance}:USERID"
end

def userpass_key(hashname, instance)
  "USER:#{hashname}:#{instance}:PASSWORD"
end

def userinst_key(id)
  # real username
  "USER:#{id}}=:INSTANCE"
end

# Get the hashed username from id
def username_key(id)
  "USER:#{id}:HASHNAME"
end
def pending_key(id)
  "TODOS:#{id}:PENDING"
end

def complete_key(id)
  "TODOS:#{id}:COMPLETE"
end

