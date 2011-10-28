module Redstore
  module Crypto
    require 'digest/sha2'
    @@fixed_salt = "f0c982f8e53f3ef08a52aa9af36aabfb335ac1bfc29d2ccb232606e364123d9a"

    def encrypt_username(name)
      # Salt is not available until we find the username
      # so use a fixed salt
      secure_hash("#{@@fixed_salt}--#{name}")
    end

    def encrypt(string, salt)
      secure_hash("#{salt}--#{string}")
    end

    def encrypt_with_salt(string, salt)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}" + rand(10000).to_s)
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

end

  #puts secure_hash("MyPass")
  #puts secure_hash("")
  #puts secure_hash("HisPass")
  #puts secure_hash("MyPass")

