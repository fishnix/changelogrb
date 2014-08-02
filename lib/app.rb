#
# ¯\_(ツ)_/¯
#
require 'rubygems'
require 'sinatra'
require 'sinatra/contrib/all'
require 'json'
require 'json-schema'
require_relative 'changelogrb'

class ChangeLogRbApp < Sinatra::Base
  register Sinatra::Contrib
  register Sinatra::ConfigFile
  use Rack::MethodOverride

  config_file '../config/config.yml'

  get "/" do
    ["ChangeLogRB!!"].join('<br />')
  end

  not_found do
    'This is nowhere to be found.'
  end

  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].name
  end
  
  post '/api/add' do
    content_type :json

    request.body.rewind
    params = JSON.parse request.body.read

    # our default response
    response = {
      :status => 500,
      :message => "Bad Request"
    }

    if params.length > 0 
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
    end
      
    json response
  end
  
  private
  
    def add_to_queue(data)
      if ENV["RACK_ENV"] == "docker"
        queue = ChangeLogRb::Queue.new({:host => ENV['QUEUE_PORT_6379_TCP_ADDR'],
                                        :port => ENV['QUEUE_PORT_6379_TCP_PORT']
                                        })
      else
        queue = ChangeLogRb::Queue.new(settings.queue)
      end
      queue.add(data)
    end
  
    def schema_valid?(data)
    # returns true/false
      JSON::Validator.validate!(settings.schema, data)
    end
  
    def schema_validate(data)
    # returns "OK" or validations error description
      begin
        JSON::Validator.validate!(settings.schema, data)
      rescue JSON::Schema::ValidationError
        return $!.message
      end
      return "OK"
    end
  
end


