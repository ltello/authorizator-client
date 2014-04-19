require 'authorizator/client/endpoints/dsl'
require 'authorizator/client/endpoints/request'

module Authorizator
  class Client

    module Endpoints
      extend  DSL
      include Request


      # ENDPOINT PATHS:

        # these paths will be accessible via the auto-created methods named after the endpoint names + '_endpoint' suffix.
        endpoint services:      '/services'
        endpoint talking_token: '/services/talking_token'


      # ENDPOINT CALLS:

        # Calls the Authorizator Service's talking_token endpoint and returns the currently valid talking token data
        # needed for services to be authorized to talk one another.
        #
        # @returns [Hash] with talking token properties.
        def talking_token
          maybe_renewing_access_token {access_token.get(talking_token_endpoint)}.parsed
        end

        # Calls the Authorizator Service's talking_token endpoint and returns the currently valid talking token data
        # needed for services to be authorized to talk one another.
        #
        # @returns [Hash] with talking token properties.
        def services
          maybe_renewing_access_token {access_token.get(services_endpoint)}.parsed['services']
        end
    end

  end
end
