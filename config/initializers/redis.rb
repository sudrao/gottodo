  if vcap = ENV['VCAP_SERVICES']
    # cloudfoundry stuff
    services = JSON.parse(vcap)
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    $redis = Redis.new redis_conf
  else
    $redis = Redis.new
    puts "Initializing redis connection. Got $redis = " + $redis.inspect
  end

