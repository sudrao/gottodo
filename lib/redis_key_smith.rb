# A module to make key string methods for Redis.
#
# Hint: See the spec file for more examples of use
#
# Use:
# 
# require 'redis_key_smith'
#
# class YourClass
#   extend RedisKeySmith
#
#   # add an instance method that takes one parameter (number or string)
#   # and returns a key string with that parameter embedded in it:
#   # user_name_key("dodo", 5) #-> "USERdodo::NAME5::"
#   rks_make_key :user_name_key, :args => 2
#
#   # Add a bunch of such methods that take 3 arguments
#   # :instance_method is the default if nothing is specified.
#   rks_make_key :user_id_key, :user_home_key, :args => 3, :instance_method => true
#
#   # Add the same methods as both instance and class methods
#   # In this case both :instance_method and :class_method options are required.
#   rks_class_make :user_id_key, :user_home_key, :args => 3, :instance_method => true, :class_method => true
#
#   # Add other class methods which do not take any arguments
#   rks_class_make :home_free, :need_to_ask, :instance_method => true, :class_method => true
#
#   # Now use these methods
#   def self.mine
#     u = $redis.get home_free
#     v = $redis.get user_id_key(5)
#     w = $redis.get user_home_key("bebo", 22)
#     x = $redis.get user_id_key(7)
#   end
# 
#   def hers
#     y = $redis.get user_name_key("who", 10)
#   end
# end
#
module  RedisKeySmith

  def rks_make_key(*params)
    options = (params.last.is_a? Hash) ? params.pop : {}
    methods = params
    args = options[:args] ? options[:args].to_i : 0
    if (options[:instance_method] || options[:class_method].nil?)
      rks_method_make(self, methods, args)
    end
    if options[:class_method]
      eigen_class = (class <<self; self; end;)
      rks_method_make(eigen_class, methods, args)
    end
  end

  private

  def rks_method_make(obj, methods, args)
    methods.each do |name|
      meth, lamb = rks_make(name, args)
      obj.send(:define_method, meth, lamb)
      #          puts "Defined #{meth} with lambda #{lamb.inspect}"
    end
  end

  def rks_make(name, args)
    words = name.to_s.split('_')
    if args > 0
      str = words[0].upcase
      args.times do |i|
        if (words[i+1])
          str << "#\{params[#{i}]\}::#{words[i+1].upcase}"
        else
          str << "#\{params[#{i}]\}::"
        end
      end
      return name, eval(<<-ENDOFEVAL
      lambda { |*params| 
        raise ArgumentError, "expected #{args}, got #\{params.length}" unless params.length == #{args}; 
        "#{str}";
      }
      ENDOFEVAL
      )
    else
      str = words.inject { |s, a| s << "::#{a}" }.upcase
      return name, eval("-> { \"#{str}\" }")
    end
  end
end
