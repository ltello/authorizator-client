shared_context "as a user:" do

  context "To use the gem, instantiate the class Authorizator::Client:

              ac = Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)

          where caller_service must be an object responding to #client_id and #client_secret and
          authorizator_service must be an object responding to #site.
          - the client_id and client_secret values returned by these methods must be the ones assigned to a registered
          client_application (service) in the Authorizator service.
          - the site value must be the complete url of the Authorizator service.

          Once you have an Authorizator::Client instance, use it to call methods of its public interface to either get
          info of the client itself of get access to the Authorizator service api in a transparent and secure way:

             ac.caller_service       #=> the same caller_service object passed when instantiating ac
             ac.authorizator_service #=> the same authorizator_service object passed when instantiating ac
             ac.talking_token        #=> the current valid talking token data a service needs to include in requests to
                                         other services to be accepted and answered.
             ac.services             #=> a list of services data the Authorizator service controls and enable talking." do
    it " " do end
  end
end
