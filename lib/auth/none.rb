require 'sinatra/base'

module Sinatra
  module NoneAuth

    module Helpers
      def authorize!
        session[:authorized] = true
        session[:user_id] = 'user'
      end

      def logout!
        session[:user_id] = nil
        session[:authorized] = false
      end
    end

    def self.registered(app)
      app.helpers NoneAuth::Helpers
      
      app.get '/logout' do
        logout!
      end
    end
  end

  register NoneAuth
end