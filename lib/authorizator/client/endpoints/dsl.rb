module Authorizator
  class Client
    module Endpoints


      module DSL

        # DSL to define a new endpoint.
        # Defines a new method named after the given endpoint name + '_endpoint' suffix returning the relative path
        # of the service url where to address requests.
        # The new method delegates into the service object if it responds_to the endpoint method or returns
        # the given path otherwise.
        #
        # @option endpoint [Symbol] :any_name given to the endpoint being its value the relative path of the endpoint.
        # @returns [String] the relative path where to access the endpoint in the service url.
        def endpoint(endpoint = {})
          endpoint_key           = endpoint.keys.first
          endpoint_path          = endpoint[endpoint_key]
          new_endpoint_methodkey = "#{endpoint_key}_endpoint".to_sym
          define_method(new_endpoint_methodkey) do
            authorizator_service.respond_to?(new_endpoint_methodkey) ? authorizator_service.send(new_endpoint_methodkey) : endpoint_path
          end
          private new_endpoint_methodkey
        end

      end


    end
  end
end
