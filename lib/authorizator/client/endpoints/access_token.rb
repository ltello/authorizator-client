require 'oauth2'

module Authorizator
  class Client
    module Endpoints

      # The class to request and instantiate access tokens from the Authorizator service, on behalf of a given service.
      # Once obtained and instantiated, an AccessToken object can make requests for resources to the Authorizator service,
      # via its verb methods: #get, #post, #put, ... #delete.
      class AccessToken < OAuth2::AccessToken

        # The scope an access token must have for a service to be authorized to request resources to the Authorizator service.
        SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE = 'myself'

        # The services to oauth-dialog using this access_token as authorization mechanism.
        attr_reader :caller_service, :authorizator_service

        # A valid access_token to be able to talk to the Authorizator service.
        #
        # @returns [Authorizator::Client::Endpoints::AccessToken] instance through which access the Authorizator service api endpoints.
        def initialize(caller_service:, authorizator_service:)
          @caller_service       = caller_service
          @authorizator_service = authorizator_service
          oauth_token           = remote_oauth_token
          oauth_token_hash      = oauth_token.to_hash
          super(oauth_token.client, oauth_token_hash.delete(:access_token), oauth_token_hash)
        end


        private

          # The remote oauth access token got from the Authorizator service.
          #
          # @returns [OAuth2::AccessToken] instance.
          def remote_oauth_token
            token = client_application.client_credentials.get_token(:scope => SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE)
            raise Error.new(token && token.params) if (!token or token.token.empty?)
            token
          end

          # An oauth client for a service to oauth-dialog with the Authorizator service. A new one if none was previously created or
          # a previous one if it was created.
          #
          # @returns [OAuth2::Client] instance.
          def client_application
            @client_application ||= new_client_application
          end

          # Creates a new oauth client a the service to oauth-dialog with the Authorizator service.
          #
          # @returns [OAuth2::Client] instance.
          def new_client_application
            OAuth2::Client.new(caller_service.client_id, caller_service.client_secret, :site => authorizator_service.site, :raise_errors => false)
          end
      end


    end
  end
end

require 'authorizator/client/endpoints/access_token/error'
