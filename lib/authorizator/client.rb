require "authorizator/client/version"
require "oauth2"

module Authorizator
  class Client

    # The scope an access token must have for a service to be authorized to request resources to the Authorizator service.
    SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE = 'myself'

    # The Authorizator service's host machine root complete url.
    AUTHORIZATOR_SERVICE_SITE = 'https://authorizator.ideas4all.com'

    # The Authorizator service api endpoint path to get the currently valid services talking token.
    AUTHORIZATOR_SERVICE_TALKING_TOKEN_ENDPOINT = '/services/talking_token'

    # The error codes the Authorizator service reports when receiving a request with an invalid access token.
    AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES = ['Invalid Access Token']


    attr_reader :service_credentials

    def initialize(service_credentials = {})
      @service_credentials = service_credentials.dup
      client_id and client_secret # raise error unless client_id and client_secret were given
    end

    # Calls the Authorizator Service talking_token endpoint and returns the currently valid talking token data
    # needed for services to be authorized to talk one another.
    def talking_token
      maybe_renewing_access_token do
        access_token.get(AUTHORIZATOR_SERVICE_TALKING_TOKEN_ENDPOINT)
      end.parsed
    end


    private

      def client_id;     service_credentials.fetch(:client_id)     end
      def client_secret; service_credentials.fetch(:client_secret) end

      # A valid access_token to be able to talk to the Authorizator service.
      #
      # @option service_credentials [String] :client_id (nil) the client_id value assigned to the caller service by the Authorizator service.
      # @option service_credentials [String] :client_secret (nil) the client_secret value assigned to the caller service by the Authorizator service.
      #
      # @returns [OAuth2::AccessToken] instance though which access Authorizator service api endpoints.
      def access_token
        @access_token ||= client_application.client_credentials.get_token(:scope => SCOPE_FOR_A_SERVICE_TO_TALK_TO_AUTHORIZATOR_SERVICE)
      end

      # An oauth client for a service to oauth-dialog with the Authorizator service.
      #
      # @option service_credentials [String] :client_id (nil) the client_id value assigned to the caller service by the Authorizator service.
      # @option service_credentials [String] :client_secret (nil) the client_secret value assigned to the caller service by the Authorizator service.
      #
      # @returns [OAuth2::Client] instance.
      def client_application
        @client_application ||= new_client_application
      end

        # Creates a new oauth client for a service to oauth-dialog with the Authorizator service.
        #
        # @param [String] client_id the client_id value assigned to the service after registering in the Authorizator service.
        # @param [String] client_secret the client_secret value assigned to the service after registering in the Authorizator service.
        # @param [String] site the Authorizator service url.
        #
        # @returns [OAuth2::Client] instance.
        def new_client_application
          OAuth2::Client.new(client_id, client_secret, :site => AUTHORIZATOR_SERVICE_SITE, :raise_errors => false)
        end

      # Calls the given block retrying once if the first response included an invalid access token error.
      #
      # @returns what block returns. Usually an [OAuth2::Response] instance.
      def maybe_renewing_access_token(&block)
        resp = block.call
        if (resp.respond_to?(:error) and resp.error and AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.include?(resp.error.code))
          @access_token = nil
          resp = block.call
        end
        resp
      end

  end
end
