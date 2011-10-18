# methods to get keys (strings) for each object in redis
module Redstore
  module Keymap
    require 'redis_key_smith'
    extend ::RedisKeySmith

    rks_make_key complete_key: 1, token_userid_key: 1, token_key_key: 1, token_secret_key: 1, evernote_secret_key: 1
  end
end

