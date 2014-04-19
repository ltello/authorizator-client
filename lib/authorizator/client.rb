require "authorizator/client/version"
require "authorizator/client/public_interface"

module Authorizator
  class Client
    include PublicInterface

    attr_reader :caller_service, :authorizator_service

    # Creates a new instance of this class with all the methods in PublicInterface available to be called from outside.
    #
    # @param [Object] caller_service must respond to #client_id and #client_secret.
    # @param [Object] authorizator_service must respond to #site.
    # @return [Authorizator::Client] new instance.
    def initialize(caller_service:, authorizator_service:)
      @caller_service       = caller_service
      @authorizator_service = authorizator_service
      caller_service.client_id and caller_service.client_secret and authorizator_service.site
    end

  end
end
