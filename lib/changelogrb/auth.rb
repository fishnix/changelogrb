module ChangeLogRb
  #
  # Default "NoAuth" module.  config looks 
  # something like this: 
  # -------------------
  # auth:
  #   provider: "ChangeLogRb::AuthNone"
  #   config: 
  #     user: 'user1'
  #
  module AuthNone
    def authenticate!
      return @authconfig['user'] || 'default'
    end
  end
end

module ChangeLogRb
  class Auth
    def initialize(args)
      @authconfig  = args[:config] || nil
      provider = args[:authprovider].constantize
      self.class.send(:include, provider)
    end
  end
end