require 'sinatra/base'
require 'securerandom'

module Sinatra
  module ChangeLogRbApp
    module Helpers
      
      def queue
        if ENV["RACK_ENV"] == "docker"
          return ChangeLogRb::Queue.new({:host => ENV['QUEUE_PORT_6379_TCP_ADDR'],
                                          :port => ENV['QUEUE_PORT_6379_TCP_PORT']
                                          })
        else
          return ChangeLogRb::Queue.new(settings.queue)
        end
      end
      
      def token_valid?(id, token)
        
        logger.debug("validating token: #{token} for id: #{id}")
        
        q = queue
        i = q.get_id_by_token(token)
        t = q.get_token_expiration(token)
        
        logger.debug("token_valid? id: #{i}, expiration: #{t}")
        
        return false if i.nil? || t.nil?
        
        if i == id && Time.parse(t).future?
          return true
        else
          return false
        end
      end
            
      def get_token
        q = queue
        return q.get_token_by_id(session[:user_id])
      end
      
      def get_token_expiraton(token)
        q = queue
        return q.get_token_expiration(token)
      end
      
      def set_token(token)
        q = queue
        q.add_token(session[:user_id], token)
        token
      end
      
      def regenerate_token
        return nil if session[:user_id].nil?
        logger.info("Regenerating token for #{session[:user_id]}.")

        token = generate_token
        set_token(token)
      end
      
      def tokinify!
        logger.debug("Tokenify!")
        id = session[:user_id]
        return nil if id.nil?
        token = get_token
        unless token_valid?(id, token)
          token = generate_token
          set_token(token)
        end
      end
      
      def add_to_queue(data)
        q = queue
        q.add(data)
        # also add to a recent redis list, so latest changes are quickly accessible
        q.add_recent(data)
      end
  
      def get_queue_recent
        q = queue
        logger.debug("Queue: #{queue.inspect}")
        q.get_recent()
      end
      
      def process_add_request(params)
        # our default response
        response = {
          :status => 500,
          :message => "Bad Request"
        }

        logger.debug("process_json_request params: #{params.inspect}")

        return response unless params.length > 0 

        schema_status = schema_validate(params) 
        if schema_status == "OK"
          # if message looks good - push it to the queue
          q_status = add_to_queue(params)
          if q_status == "OK"
            response[:status] = 200
            response[:message] = "Success"
          else
            # adding to the queue failed
            response[:message] = "Bad request: Could not add to queue (#{q_status})"
          end
          logger.debug "Got #{params.inspect}"

        else
          # schema validation failed
          response[:message] = "Bad request: JSON schema validation failed (#{schema_status})"
        end

        return response
      end  
      
      private
        def generate_token
          logger.debug("Generating random token...")
          return SecureRandom.urlsafe_base64
        end
        
        def strip_from(params, key)
          logger.debug("Cleaning up params: #{params.inspect}")
          params.delete(key) 
          logger.debug("Clean params: #{params.inspect}")
        end
    end
  end
end
