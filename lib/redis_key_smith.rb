# A module to make key string methods for Redis.
#
# Hint: See the spec file for examples of use
#
# Use:
# 
# class YourClass
#   extend RedisKeySmith
#
#   # add an instance method that takes one parameter (number or string)
#   # and returns a key string with that parameter embedded in it:
#   # user_name_key("dodo", 5) #-> "USERdodo::NAME5::"
#   rks_instance_make :user_name_key => 2
#
#   # Add a bunch of such methods. The value 1, 2, etc. are the number of parameters
#   # that method will take.
#   rks_instance_make :user_id_key => 1, :user_home_key => 2
#
#   # Add the same methods as class methods
#   rks_class_make :user_id_key => 1, :user_home_key => 2
#
#   # Add other class methods which do not take any parameter
#   rks_class_make :home_free, :need_to_ask
#
#   # Now use these methods
#   def self.mine
#     u = $redis.get home_free
#     v = $redis.get user_id_key(5)
#     w = $redis.get user_home_key("bebo", 22)
#   end
# 
#   def hers
#     x = $redis.get user_name_key("who", 10)
#   end
# end
#
module  RedisKeySmith

  def rks_instance_make(*params)
    rks_method_make(self, 'orig' => params)
  end

  def rks_class_make(*params)
    eigen_class = (class <<self; self; end;)
    rks_method_make(eigen_class, 'orig' => params)
  end

  private

  def rks_method_make(obj, inhash)
    params = inhash['orig']
    params.each do |param|
      if param.is_a? Hash
        param.each do |k, v|
          meth, lamb = rks_make(k => v)
          obj.send(:define_method, meth, lamb)
          #          puts "Defined #{meth} with lambda #{lamb.inspect}"
        end
      else
        meth, lamb = rks_make(param)
        obj.send(:define_method, meth, lamb)
        #        puts "Defined #{meth} with lambda #{lamb.inspect}"
      end
    end
  end

  def rks_make(param)
    if (param.is_a? Hash) # single key in this hash
      param.each do |k, v|
        words = k.to_s.split('_')
        str = words[0].upcase
        v.times do |i|
          if (words[i+1])
            str << "#\{params[#{i}]\}::#{words[i+1].upcase}"
          else
            str << "#\{params[#{i}]\}::"
          end
        end
        return k, eval("lambda { |*params| \"#{str}\" }") # method, lambda
      end
    else
      str = param.to_s.split('_').inject { |s, a| s << "::#{a}" }.upcase
      return param, eval("-> { \"#{str}\" }") # method, lambda
    end
  end
end
