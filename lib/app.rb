#
# ¯\_(ツ)_/¯
#
require 'sinatra'
require 'sinatra/contrib/all'
require 'json'
# %w{rubygems sinatra}.each {|l| require l }

class ChangeLogRbApp < Sinatra::Base
  register Sinatra::Contrib

  use Rack::MethodOverride

  # config_file 'config.yml'
  set :protection, :except => :frame_options

  get "/" do
    ["ChangeLogRB!!"].join('<br />')
  end

  post '/add' do
    content_type :json

    request.body.rewind  # in case someone already read it
    params = JSON.parse request.body.read

    response = Hash.new
  
    if params.length == 0
      response[:status] = 500
      response[:message] = "Bad Request"
    else
      response[:status] = 200
      logger.info "Got #{params.inspect}"
    end
  
    json response
  end

  not_found do
    'This is nowhere to be found.'
  end

  error do
    'Sorry there was a nasty error - ' + env['sinatra.error'].name
  end

  private
  
end


