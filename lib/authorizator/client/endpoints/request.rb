require 'authorizator/client/endpoints/response'
require 'authorizator/client/endpoints/access_token'

module Authorizator
  class Client
    module Endpoints


      module Request
        include Response

        private

          # A valid access_token to be able to talk to the Authorizator service.
          #
          # @return [Authorizator::Client::Endpoints::AccessToken] instance through which access the Authorizator service api endpoints.
          def access_token
            @access_token ||= AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)
          end

          # Calls the given block retrying once if the first response included an invalid access token error.
          #
          # @return what block returns. Usually an [OAuth2::Response] instance.
          def maybe_renewing_access_token(&block)
            first_attempt_request(&block) or (renew_access_token! and last_attempt_request(&block))
          end

            # Calls the given block once and returns response if it is not invalid.
            #
            # @return [Object] response or nil.
            def first_attempt_request(&block)
              resp = block.call
              resp unless invalid_access_token_response?(resp)
            end

            # Removes the currently stored access token to be renewed in the following call.
            #
            # @return [Boolean] true.
            def renew_access_token!
              @access_token = nil
              true
            end

            # Calls the given block the last time and returns response if it is not invalid.
            # Raises an error otherwise.
            #
            # @return [Object] response or raises an Exception.
            def last_attempt_request(&block)
              resp  = block.call
              error = invalid_access_token_response?(resp)
              error ? raise(error) : resp
            end
      end


    end
  end
end
