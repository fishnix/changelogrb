# require 'sinatra/base'
require 'active_support/all'
require 'rubycas-client'

module Sinatra
  module CasAuth

    module Helpers
      
      def authorized?
        session[:authorized] && session[:cas_ticket] && !session[:cas_ticket].empty?
      end

      def authorize!
        unless authorized?
          logger.debug("session not authorized, attempting to CAS auth")
          
          cas_client = CASClient::Client.new( :cas_base_url => @auth['config']['base_url'],
                                              :log => Logger.new(STDOUT), 
                                              :ticket_store_config =>  @auth['config'][':ticket_store_config'])
                                              
          if request[:ticket] && request[:ticket] != session[:ticket]
            logger.debug("found a ticket: #{session[:ticket]}, validating")
            
            service_url = read_service_url(request)
            st = read_ticket(request[:ticket], service_url)

            cas_client.validate_service_ticket(st)

            if st.success              
              session[:cas_ticket] = st.ticket
              session[:user_id] = st.user
              session[:authorized] = true
              logger.debug("successfully validated ticket #{session[:ticket]}, setting cas_ticket #{session[:cas_ticket]} and user #{session[:user_id]}")
              
            else
              logger.debug("failed to validate ticket #{session[:ticket]}")
              raise "Service Ticket validation failed! #{st.failure_code} - #{st.failure_message}"
            end
          else
            logger.debug("didnt find a ticket, redirecting to CAS")
            service_url = read_service_url(request)
            url = cas_client.add_service_to_login_url(service_url)
            redirect url
          end
          true
        else
          
        end
      end

      def logout!
        logger.debug("killing session: #{session.inspect}")
        session.clear
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
      
      # puts "#{self.inspect}"
      
      app.get '/logout' do
        logout!
      end
    end
  end

  register CasAuth
end