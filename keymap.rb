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

def userlist_key(username)
  # Set of possibly duplicate names
  # distinguished by numeric extension
  "USER:#{username}:USERLIST"
end

# only username+realname is guaranteed to be unique
def userid_key(username, realname)
  "USER:{usernme}:{realname}:USERID"
end

def userpass_key(username, realname)
  "USER:#{username}:#{realname}:PASSWORD"
end

def username_key(id)
  # real username
  "USER:#{id}}=:USERNAME"
end

def basename_key(id)
  "USER:#{id}:BASENAME"
end
def pending_key(id)
  "TODOS:#{id}:PENDING"
end

def complete_key(id)
  "TODOS:#{id}:COMPLETE"
end

