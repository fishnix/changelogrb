module ChangeLogRb  
  class Queue
    require 'redis'
    require 'date'
    require 'json'
    
    def initialize(args)
      redis_host  = args[:host] || '127.0.0.1'
      redis_port  = args[:port] || '6379'
      @redis = Redis.new(:host => redis_host, :port => redis_port)
    end
    
    def add(cl)
      cl_json = cl.to_json
      begin
        @redis.rpush("changelog", cl_json)
        "OK"
      rescue => e
        "ERROR: #{e}"
      end
    end
  end
end
