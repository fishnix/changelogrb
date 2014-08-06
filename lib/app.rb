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

  set :root, File.dirname(File.dirname(__FILE__))
  config_file 'config/config.yml'

  get "/" do
    erb :index
  end

  get "/add" do
    erb :add
  end

  get "/list" do
    recent_list = get_queue_recent
    erb :list, locals: { recent_list: recent_list }
  end

  post '/api/add' do
    content_type :json

    request.body.rewind
    params = JSON.parse request.body.read

    json process_add_request(params)
  end
  
  not_found do
    'This is nowhere to be found.'
  end

  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].name
  end
  
  helpers do

    def process_add_request(params)
      # our default response
      response = {
        :status => 500,
        :message => "Bad Request"
      }

      puts "process_json_request params: #{params.inspect}"

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
  
    def schema_valid?(data)
    # returns true/false
      JSON::Validator.validate(settings.schema, data)
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

