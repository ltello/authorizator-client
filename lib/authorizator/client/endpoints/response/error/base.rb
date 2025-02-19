module Authorizator
  class Client
    module Endpoints
      module Response


        module Error

          # The base RuntimeError subclass to raise when an invalid response is received from the Authorizator service.
          # More specific error conditions in the response received from the remote Authorizator service, must be subclasses
          # of this base class.
          class Base < RuntimeError
            # The data to add to the message when the exception instance is raised.
            attr_reader :msg, :data

            def initialize(msg:, data:)
              @msg, @data = msg, data
            end

            def message
              "#{msg}: #{data}"
            end
          end

        end


      end
    end
  end
end
