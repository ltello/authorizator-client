require "authorizator/client/version"
require "oauth2"

module Authorizator
  class Client

    # The scope an access token must have for a service to be authorized to request resources to the Authorizator service.
    SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE = 'myself'

    # The Authorizator service api endpoint path to get the currently valid services talking token.
    DEFAULT_AUTHORIZATOR_SERVICE_TALKING_TOKEN_ENDPOINT = '/services/talking_token'

    # The Authorizator service api endpoint path to get the list of services secured by the Authorizator.
    DEFAULT_AUTHORIZATOR_SERVICE_SERVICES_ENDPOINT = '/services'

    # The error codes the Authorizator service reports when receiving a request with an invalid access token.
    AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES = ['Invalid Access Token']


    attr_reader :caller_service, :authorizator_service


    def initialize(caller_service:, authorizator_service:)
      @caller_service       = caller_service
      @authorizator_service = authorizator_service
      caller_service.client_id and caller_service.client_secret and authorizator_service.site
    end

    # Calls the Authorizator Service's talking_token endpoint and returns the currently valid talking token data
    # needed for services to be authorized to talk one another.
    #
    # @returns [Hash] with talking token properties.
    def talking_token
      maybe_renewing_access_token do
        access_token.get(talking_token_endpoint)
      end.parsed
    end

    # Calls the Authorizator Service's talking_token endpoint and returns the currently valid talking token data
    # needed for services to be authorized to talk one another.
    #
    # @returns [Hash] with talking token properties.
    def services
      maybe_renewing_access_token do
        access_token.get(services_endpoint)
      end.parsed['services']
    end


    private

      # A valid access_token to be able to talk to the Authorizator service.
      #
      # @returns [OAuth2::AccessToken] instance through which access the Authorizator service api endpoints.
      def access_token
        return @access_token if instance_variable_defined?(:@access_token)
        new_token = client_application.client_credentials.get_token(:scope => SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE)
        raise("Got invalid access token: #{new_token.params}") if (!new_token or new_token.token.empty?)
        @access_token = new_token
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

      # Calls the given block retrying once if the first response included an invalid access token error.
      #
      # @returns what block returns. Usually an [OAuth2::Response] instance.
      def maybe_renewing_access_token(&block)
        resp = block.call
        if invalid_remote_reponse?(resp)
          @access_token = nil
          resp = block.call
          error = invalid_remote_reponse?(resp)
          raise(error) if error
        end
        resp
      end

        def invalid_remote_reponse?(resp)
          return false unless (resp.respond_to?(:error) and resp.error)
          return resp.error.code if AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.include?(resp.error.code)
          AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.each do |code|
            return code if resp.headers['www-authenticate'] =~ Regexp.new(code)
          end
          false
        end

      # The relative path of the Authorizator service url that gives you a valid talking token.
      #
      # @returns [String] instance. i.e. /services/talking_token
      def talking_token_endpoint
        authorizator_service.respond_to?(:talking_token_endpoint) ? authorizator_service.talking_token_endpoint : DEFAULT_AUTHORIZATOR_SERVICE_TALKING_TOKEN_ENDPOINT
      end

      # The relative path of the Authorizator service url that gives you the list of services secured by the Authorizator..
      #
      # @returns [String] instance. i.e. /services/services
      def services_endpoint
        authorizator_service.respond_to?(:services_endpoint) ? authorizator_service.services_endpoint : DEFAULT_AUTHORIZATOR_SERVICE_SERVICES_ENDPOINT
      end

  end
end
