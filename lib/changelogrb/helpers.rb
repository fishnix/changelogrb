require 'sinatra/base'

module Sinatra
  module ChangeLogRbApp
    module Helpers
      
      # Check if there is a user_id in the session      
      def is_authenticated?
        logger.debug("Checking if logged in... Session: #{session.inspect}")
        return !!session[:user_id]
      end
      
      # Unless already authenticated, authenticate!
      def require_logged_in
        unless is_authenticated?
          @authprov = ChangeLogRb::Auth.new({ :authprovider => settings.auth['provider'],
                                              :config => settings.auth['config']
                                            })
          session[:user_id] = @authprov.authenticate!
        end
      end
  
      def add_to_queue(data)
        if ENV["RACK_ENV"] == "docker"
          queue = ChangeLogRb::Queue.new({:host => ENV['QUEUE_PORT_6379_TCP_ADDR'],
                                          :port => ENV['QUEUE_PORT_6379_TCP_PORT']
                                          })
        else
          queue = ChangeLogRb::Queue.new(settings.queue)
        end
        queue.add(data)
        # also add to a recent redis list, so latest changes are quickly accessible
        queue.add_recent(data)
      end
  
      def get_queue_recent()
        if ENV["RACK_ENV"] == "docker"
          queue = ChangeLogRb::Queue.new({:host => ENV['QUEUE_PORT_6379_TCP_ADDR'],
                                          :port => ENV['QUEUE_PORT_6379_TCP_PORT']
                                          })
        else
          queue = ChangeLogRb::Queue.new(settings.queue)
        end
        queue.get_recent()
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
    end
  end
end