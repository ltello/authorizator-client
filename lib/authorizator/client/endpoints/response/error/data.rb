require 'authorizator/client/endpoints/response/error/base'

module Authorizator
  class Client
    module Endpoints
      module Response
        module Error


          # The exception to raise when data received from the Authorizator service is invalid.
          class Data < Base

            def initialize(msg: "Got invalid data from Authorizator service", data:)
              super
            end

          end


        end
      end
    end
  end
end
