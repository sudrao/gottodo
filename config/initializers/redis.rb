  if vcap = ENV['VCAP_SERVICES']
    # cloudfoundry stuff
    services = JSON.parse(vcap)
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    $redis = Redis.new redis_conf
  else
    redis_conf = {:port => Rails.env.test? ? 6378 : 6379}
    Ohm.connect(redis_conf)
    $redis = Ohm.redis
    puts "Initializing redis connection. Got $redis = " + $redis.inspect
  end

