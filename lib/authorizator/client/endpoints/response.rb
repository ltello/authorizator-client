require 'authorizator/client/endpoints/response/error_checking'

module Authorizator
  class Client
    module Endpoints


      module Response
        include ErrorChecking

        private

          # The error codes the Authorizator service reports when receiving a request with an invalid access token.
          AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES = ['Invalid Access Token']

          # Checks whether a response from the Authorizator service states an error or not.
          #
          # @return [false, Object]: an error code or false if not invalid response.
          def invalid_access_token_response?(resp)
            AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.each do |code|
              return code if resp.headers['www-authenticate'] =~ Regexp.new(code)
            end if resp.respond_to?(:headers)
            return false unless (resp.respond_to?(:error) and resp.error)
            return resp.error.code if AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.include?(resp.error.code)
            false
          end

      end


    end
  end
end
