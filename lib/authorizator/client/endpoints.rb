require 'authorizator/client/endpoints/dsl'
require 'authorizator/client/endpoints/request'
require 'authorizator/client/endpoints/response/error/data'


module Authorizator
  class Client

    module Endpoints
      extend  DSL
      include Request

      # ENDPOINT PATHS:

        # these paths will be accessible via the auto-created methods named after the endpoint names + '_endpoint' suffix.
        endpoint services:      '/services'
        endpoint talking_token: '/services/talking_token'


      # ENDPOINT CALLS:

        # Calls the Authorizator Service's talking_token endpoint and returns the currently valid talking token data
        # needed for services to be authorized to talk one another.
        #
        # @return [Hash] with talking token properties.
        # @see #check_received_talking_token_endpoint_data! for exact properties format.
        def talking_token
          remote_talking_token_data = maybe_renewing_access_token {access_token.get(talking_token_endpoint)}.parsed
          check_received_talking_token_endpoint_data!(remote_talking_token_data)
        end

        # Calls the Authorizator Service's services endpoint and returns data of the playing services the Authorizator
        # is providing talking security.
        #
        # @return [Hash] with services properties.
        # @see #check_received_services_endpoint_data! for exact properties format.
        def services
          remote_services_data = maybe_renewing_access_token {access_token.get(services_endpoint)}.parsed
          check_received_services_endpoint_data!(remote_services_data)['services']
        end


      private

          # Checks received talking token data format from Authorizator service, raising errors if any check fails:
          # Format must be: {'access_token' => 'no_empty_string',
          #                  'token_type'   => 'bearer',
          #                  'expires_in'   => 'positive number string',
          #                  'scope'        => 'service_mate'}
          # @return [Object] talking_token_data if every check is ok!.
          def check_received_talking_token_endpoint_data!(data)
            [:access_token, :token_type, :expires_in, :scope].each {|key| check_key_present_in_endpoint_data! key:key,  data:data, endpoint: :talking_token}
            check_key_value_is_no_empty_string_in_endpoint_data!        key:'access_token', value:data['access_token'], data:data, endpoint: :talking_token
            check_key_value_is_some_fix_value_in_endpoint_data!         key:'token_type',   value:data['token_type'],   data:data, endpoint: :talking_token, must_be:'bearer'
            check_key_value_is_positive_number_string_in_endpoint_data! key:'expires_in',   value:data['expires_in'],   data:data, endpoint: :talking_token
            check_key_value_is_some_fix_value_in_endpoint_data!         key:'scope',        value:data['scope'],        data:data, endpoint: :talking_token, must_be:'service_mate'
            data
          end

          # Checks received services data format from Authorizator service, raising errors if any check fails:
          # Format must be: {'services' => [{'name' => 'no_empty_string', 'site' => 'no empty string'},
          #                                                       ...
          #                                 {'name' => 'no_empty_string', 'site' => 'no empty string'}]}
          # @return [Object] services_data if every check is ok!.
          def check_received_services_endpoint_data!(data)
            check_key_present_in_endpoint_data! key:'services', data:data, endpoint: :services
            check_key_value_is_array_in_endpoint_data! key:'services', value:data['services'], data:data, endpoint: :services
            data['services'].each do |service_data|
              [:name, :site].each {|key| check_key_present_in_endpoint_data! key:key, data:service_data, endpoint: :services}
              check_key_value_is_no_empty_string_in_endpoint_data! key:'name', value:service_data['name'], data:service_data, endpoint: :services
              check_key_value_is_no_empty_string_in_endpoint_data! key:'site', value:service_data['site'], data:service_data, endpoint: :services
            end
            data
          end
    end

  end
end
