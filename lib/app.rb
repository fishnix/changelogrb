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

  config_file '../config.yml'

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

    response = {
      :status => 500,
      :message => "Bad Request"
    }
    
    valid_schema = JSON::Validator.validate(settings.schema, params)
    
    if params.length > 0 && valid_schema 
            
      if add_to_queue(params) == "OK"
        response[:status] = 200
        response[:message] = "Succes"
      end
      logger.debug "Got #{params.inspect}"
    end
      
    json response
  end
  
  private
  
  def add_to_queue(data)
    queue = ChangeLogRb::Queue.new(settings.queue)
    queue.add(data)
  end
  
end


