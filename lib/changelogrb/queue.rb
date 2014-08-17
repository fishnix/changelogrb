module ChangeLogRb  
  class Queue
    require 'redis'
    require 'date'
    require 'json'
    require 'active_support/all'
    
    def initialize(args)
      redis_host  = args[:host] || '127.0.0.1'
      redis_port  = args[:port] || '6379'
      @redis = Redis.new(:host => redis_host, :port => redis_port)
      @recent_count = args[:recent] || 100
      @token_ttl = args[:token_ttl] || 36000
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

    def get_recent
      begin
        @redis.lrange("changelog.recent", 0, -1)
      rescue => e
        "ERROR: #{e}"
      end
    end
    
    def add_tag(tag)
      # we use an unordered set to store the tags
      begin
        @redis.sadd("changelog.tags", tag)
        "OK"
      rescue => e
        "ERROR: #{e}"
      end
    end

    def get_tags
      begin
        @redis.smembers("changelog.tags")
      rescue => e
        "ERROR: #{e}"
      end
    end
    
    def add_token(id, token)
      begin
        @redis.hset("changelog.token_by_id", id, token)
        @redis.hset("changelog.id_by_token", token, id)
        @redis.hset("changelog.token_expiration", token, Time.now + @token_ttl.seconds)
      rescue => e
        "ERROR: #{e}"
      end
    end
    
    def get_token_expiration(token)
      begin
        return @redis.hget("changelog.token_expiration", token)
      rescue => e
        "ERROR: #{e}"
      end
    end
    
    def get_id_by_token(token)
      begin
        return @redis.hget("changelog.id_by_token", token)
      rescue => e
        "ERROR: #{e}"
      end
    end
    
    def get_token_by_id(id)
      begin
        return @redis.hget("changelog.token_by_id", id)
      rescue => e
        "ERROR: #{e}"
      end
    end
    
  end
end
