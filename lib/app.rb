#
# ¯\_(ツ)_/¯
#
require 'rubygems'
require 'sinatra/base'
require 'sinatra/contrib/all'
require 'json'
require 'json-schema'
require_relative 'changelogrb'

class ChangeLogRbApp < Sinatra::Base
  register Sinatra::Contrib
  register Sinatra::ConfigFile
  register Sinatra::CasAuth
  use Rack::MethodOverride
  helpers Sinatra::ChangeLogRbApp::Helpers
  
  set :sessions, true
  set :logging, true
  set :root, File.dirname(File.dirname(__FILE__))
  configure(:development) { 
    set :session_secret, "secret"
    set :logging, :debug
  }

  config_file 'config/config.yml'
    
  before "/ui/*" do
    @auth = settings.auth
    authorize!
  end

  get "/" do
    redirect '/ui/add'
  end

  get "/ui/add" do
    erb :add, locals: { user_id: session[:user_id], token: get_token }
  end

  get "/ui/list" do
    recent_list = get_queue_recent
    erb :list, locals: { recent_list: recent_list }
  end

  get "/ui/token/:action" do
    if params[:action] == "show"
      token = get_token
      expiry = get_token_expiraton(token)
      erb :token, locals: { user_id: session[:user_id], token: get_token, expiry: expiry }
    elsif params[:action] == "regenerate"
      set_token(generate_token)
      redirect to('/ui/token/show')
    elsif params[:action] == "generate" && get_token.nil?
      set_token(generate_token)
      redirect back
    else
      error
    end
  end

  post '/api/add' do
    content_type :json

    request.body.rewind
    params = JSON.parse request.body.read

    logger.info("Got JSON params: #{params.inspect}")

    if token_valid?(params["user"], params["token"])
      response = process_add_request(params)
    else
      response = {
          :status => '401',
          :message => "Unauthorized"
        }
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

