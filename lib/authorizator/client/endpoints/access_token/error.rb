module Authorizator
  class Client
    module Endpoints
      class AccessToken


        # The RuntimeError subclass to raise when an invalid access token is received from the Authorizator service.
        class Error < RuntimeError

          # The data to add to the message when the exception instance is raised.
          attr_reader :data

          def initialize(data={})
            @data = data
          end

          def message
            "Got invalid access token: #{data}"
          end

        end


      end
    end
  end
end
