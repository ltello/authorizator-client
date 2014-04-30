require 'spec_helper'

describe "Run README_FOR_USERS test to learn the goals of this gem for a user!
          To maintain this gem and include new features to users, two concepts are the most important ones:

            1.- Endpoints (authorizator/client/endpoints.rb): in this file you define the methods a gem's user will call
                to access the Authorizator api endpoints urls.
                To define a new endpoint, use the macro .endpoint and include yours in the #ENDPOINTS PATHS section:

                  # ENDPOINT PATHS:

                    # these paths will be accessible via the auto-created methods named after the endpoint names + '_endpoint' suffix.
                    :new_endpoint_name => '/relative_path_in_authorizator_service_hostname'

                this macro will meta-define a private method #new_endpoint_name_endpoint that returns the given path
                '/relative_path_in_authorizator_service_hostname' or the one stated in the authorizator_service object
                if it respond_to the method and defines an specific path.
                you will need #new_endpoint_name_endpoint to be call when defining the method that make the request to the endpoint.

                Once the new endpoint is defined, create a public method to make requests to that Authorizator's endpoint url
                using #access_token and #maybe_renewing_access_token helper methods. For instance:

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

                so, the gem user now can call authorizator_client_instance.talking_token and be returned a hash after the .json data
                received after the request made.

                It is very important to error check the data before being returned. To do that, you can use the error-checking
                helpers defined in /authorizator/client/response/error-checking.rb or even add your own ones. Example:

                    # Checks received talking token data format from Authorizator service, raising errors if any check fails:
                    # Format must be: {'access_token' => 'no_empty_string',
                    #                  'token_type'   => 'bearer',
                    #                  'expires_in'   => 'positive number',
                    #                  'scope'        => 'service_mate'}
                    # @return [Object] talking_token_data if every check is ok!.
                    def check_received_talking_token_endpoint_data!(data)
                      [:access_token, :token_type, :expires_in, :scope].each {|key| check_key_present_in_endpoint_data! key:key,  data:data, endpoint: :talking_token}
                      check_key_value_is_no_empty_string_in_endpoint_data! key:'access_token', value:data['access_token'], data:data, endpoint: :talking_token
                      check_key_value_is_some_fix_value_in_endpoint_data!  key:'token_type',   value:data['token_type'],   data:data, endpoint: :talking_token, must_be:'bearer'
                      check_key_value_is_positive_number_in_endpoint_data! key:'expires_in',   value:data['expires_in'],   data:data, endpoint: :talking_token
                      check_key_value_is_some_fix_value_in_endpoint_data!  key:'scope',        value:data['scope'],        data:data, endpoint: :talking_token, must_be:'service_mate'
                      data
                    end


            2.- Public Interface (authorizator/client/public_interface.rb): in this file you define the methods a gem's user
                will also call to get info from the Authorizator service but indirectly proccessing received endpoints data.
                The idea is to keep endpoint methods tightly associated to the corresponding remote endpoints and the rest of
                methods publicly accessible to be a processing of those endpoints data before returning.
                To define a new no-endpoint method, do it in this file. Example:

                  # Whether to sign up the user with the provided data or not.
                  # @see CortefielUser::Client#get_user documentation for a list of entries to include in user_data arg.
                  #
                  # @returns [Boolean]
                  def is_registrable?(**user_data)
                    get_user(user_data).has_key?(:sap_id)
                  end

                This method is using #get_user endpoint previously defined method, to proccess the received data before returning
                a result.

          Final Note: dont forget to create detailed tests in /spec folder for the new exposed methods!
                      Remember brasaas maintenance painfull times!" do
  it "" do
    expect(true).to be_true
  end
end
