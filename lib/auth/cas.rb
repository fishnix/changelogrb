require 'sinatra/base'
require 'active_support/all'
require 'rubycas-client'

module Sinatra
  module CasAuth

    module Helpers
      
      CAS_CLIENT = CASClient::Client.new( :cas_base_url => "https://secure.its.yale.edu/cas",
                                          :log => Logger.new(STDOUT), 
                                          :ticket_store_config => {:storage_dir => '.'})
      
      def authorized?
        session[:authorized] && session[:cas_ticket] && !session[:cas_ticket].empty?
      end

      def authorize!
        unless authorized?
          if request[:ticket] && request[:ticket] != session[:ticket]

            service_url = read_service_url(request)
            st = read_ticket(request[:ticket], service_url)

            CAS_CLIENT.validate_service_ticket(st)

            if st.success
              session[:cas_ticket] = st.ticket
              session[:user_id] = st.user
              session[:authorized] = true
            else
              raise "Service Ticket validation failed! #{st.failure_code} - #{st.failure_message}"
            end
          else
            service_url = read_service_url(request)
            url = CAS_CLIENT.add_service_to_login_url(service_url)
            redirect url
          end
        end
      end

      def logout!
        # CAS_CLIENT.logout!
        session[:authorized] = false
      end
      
      def read_ticket(ticket_str, service_url)
        return nil unless ticket_str and !ticket_str.empty?

        if ticket_str =~ /^PT-/
          CASClient::ProxyTicket.new(ticket_str, service_url)
        else
          CASClient::ServiceTicket.new(ticket_str, service_url)
        end
      end

      def read_service_url(request)
        service_url = url(request.path_info)
        if request.GET
          params = request.GET.dup
          params.delete(:ticket)
          if params
            [service_url, Rack::Utils.build_nested_query(params)].join('?')
          end
        end
        return service_url
      end
    end

    def self.registered(app)
      app.helpers CasAuth::Helpers
      
      app.get '/logout' do
        logout!
      end
    end
  end

  register CasAuth
end