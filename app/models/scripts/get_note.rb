require 'evernote'
require 'fileutils'
require 'yaml'

module Scripts
  class GetNote

    def self.run
      user_store_url = "https://sandbox.evernote.com/edam/user"
      config = YAML::load_file('evernote.yml')
      user_store = Evernote::UserStore.new(user_store_url, config)

      auth_result = user_store.authenticate
      user = auth_result.user
      auth_token = auth_result.authenticationToken
      puts "Authentication was successful for #{user.username}"
      puts "Authentication token = #{auth_token}"
    end
  end
end

#GetNote.run
