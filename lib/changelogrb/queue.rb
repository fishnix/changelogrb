module ChangeLogRb  
  class Queue
    require 'redis'
    require 'date'
    require 'json'
    
    def initialize(args)
      redis_host  = args[:host] || '127.0.0.1'
      redis_port  = args[:port] || '6379'
      @redis = Redis.new(:host => redis_host, :port => redis_port)
      @recent_count = args[:recent] || 100
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

    def add_recent(cl)
      cl_json = cl.to_json
      begin
        @redis.lpush("changelog.recent", cl_json)
        # only keep the X most-recent entries in this list
        @redis.ltrim("changelog.recent", 0, @recent_count)
        "OK"
      rescue => e
        "ERROR: #{e}"
      end
    end

    def get_recent()
      begin
        @redis.lrange("changelog.recent", 0, -1)
      rescue => e
        "ERROR: #{e}"
      end
    end
  end
end
