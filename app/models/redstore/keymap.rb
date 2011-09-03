# methods to get keys (strings) for each object in redis
module Redstore
  module Keymap

    # module methods
    def self.usercount_key
      # Global count of users
      # Does not decrement even if user removed
      "USER::USERCOUNT"
    end

    def self.todocount_key
      # Global count of todos
      # Does not decrement even if todo removed
      "TODO::TODOCOUNT"
    end

    def self.tokencount_key
      # Global count of tokens
      "TOKEN::TOKENCOUNT"
    end
    
    # regular methods
    def userlist_key(hashname)
      # Set of possibly duplicate names
      # distinguished by numeric extension
      "USER:#{hashname}:USERLIST"
    end

    # only hashname+instance is guaranteed to be unique
    def userid_key(hashname, instance)
      "USER:#{hashname}:#{instance}:USERID"
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
    
    def token_userid_key(id)
      "TOKEN:#{id}:USERID"
    end
    
    def token_key_key(id)
      "TOKEN:#{id}:KEY"
    end
    
    def token_secret_key(id)
      "TOKEN:#{id}:SECRET"
    end
    
    def evernote_secret_key(id)
      "EVERNOTE:#{id}:SECRET"
    end
  end
end

