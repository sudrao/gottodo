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
