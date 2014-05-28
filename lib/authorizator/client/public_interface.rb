require 'authorizator/client/endpoints'

module Authorizator
  class Client

    module PublicInterface
      include Endpoints

      # Add here no-endpoints methods you want to be called from a gem/application using this one.
      # That is, methods part of the public interface of an AuthorizatorClient instance.
      # Basically these methods will call one/some endpoint method/s and do some processing before
      # returning a result.

      # Checks that the Authorizator Service url is reachable.
      #
      # @return [Boolean]
      def accessible?
        services rescue (return false)
        true
      end
    end

  end
end
