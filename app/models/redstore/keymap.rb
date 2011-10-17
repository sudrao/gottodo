# methods to get keys (strings) for each object in redis
module Redstore
  module Keymap
    require 'redis_key_smith'
    extend ::RedisKeySmith

    rks_class_make :usercount_key, :tokencount_key
    rks_instance_make userlist_key: 1, userid_key: 2, userpass_key: 2, userinst_key: 1, username_key: 1, usersalt_key: 1, pending_key:1
    rks_instance_make complete_key: 1, token_userid_key: 1, token_key_key: 1, token_secret_key: 1, evernote_secret_key: 1
    rks_instance_make :todocount_key
    rks_instance_make todostart_key: 1, todobody_key: 1, todorecur_key: 1, todouser_key: 1
    rks_class_make todostart_key: 1, todobody_key: 1, todorecur_key: 1, todouser_key: 1
  end
end

