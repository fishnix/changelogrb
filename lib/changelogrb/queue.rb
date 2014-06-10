module ChangeLogRb  
  class Queue
    require 'redis'
    require 'date'
    require 'json'
    
    def initialize(args, logger)
      redis_host  = args[:host] || '127.0.0.1'
      redis_port  = args[:port] || '6379'
      @logger     = logger
      @redis = Redis.new(:host => redis_host, :port => redis_port)
    end
    
    def add(cl)
      @logger.debug("add - start")
      cl_json = cl.to_json
      begin
        @logger.debug("add - Adding changelog: #{cl_json}")
        @redis.rpush("changelog", cl_json)
        "OK"
      rescue
        @logger.error("add - Couldn't write to redis!")
        "ERROR"
      end
    end
  end
end