#
# ¯\_(ツ)_/¯
#
require 'sinatra'
require 'sinatra/contrib/all'
require 'json'
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

    request.body.rewind  # in case someone already read it
    params = JSON.parse request.body.read

    response = Hash.new
  
    if params.length == 0
      response[:status] = 500
      response[:message] = "Bad Request"
    else
      queue = ChangeLogRb::Queue.new(settings.queue, logger)
      status = queue.add(params)
      
      if status == "OK"
        response[:status] = 200
      else
        response[:status] = 500
      end
      logger.debug "Got #{params.inspect}"
    end
  
    json response
  end
  
end


