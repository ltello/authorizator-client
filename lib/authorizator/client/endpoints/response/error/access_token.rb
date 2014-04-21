require 'authorizator/client/endpoints/response/error/base'

module Authorizator
  class Client
    module Endpoints
      module Response
        module Error


          # The exception to raise when an invalid access token is received from the Authorizator service.
          class AccessToken < Base

            def initialize(msg: "Got invalid access token", data:)
              super
            end

          end


        end
      end
    end
  end
end
