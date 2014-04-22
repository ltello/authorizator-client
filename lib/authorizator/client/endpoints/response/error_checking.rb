require 'authorizator/client/endpoints/response/error/data'

module Authorizator
  class Client
    module Endpoints
      module Response


        module ErrorChecking

          private

            # Raises an Error::Data exception if the given :key from :endpoint :data is missing.
            def check_key_present_in_endpoint_data!(key:, data:, endpoint:)
              raise_missing_key_in_data(key: key, data: data, endpoint: endpoint) unless data.has_key?(key.to_s)
            end

            # Raises an Error::Data exception if the given :key :value from :endpoint :data is not an Array instance.
            def check_key_value_is_array_in_endpoint_data!(key:, value:, data:, endpoint:)
              raise_invalid_value_in_data(key: key, value: value, must_be: 'array', data: data, endpoint: endpoint) unless value.is_a?(Array)
            end

            # Raises an Error::Data exception if the given :key :value from :endpoint :data is not a non-empty String instance.
            def check_key_value_is_no_empty_string_in_endpoint_data!(key:, value:, data:, endpoint:)
              raise_invalid_value_in_data(key: key, value: value, must_be: 'no empty string', data: data, endpoint: endpoint) unless (value.is_a?(String) and !value.empty?)
            end

            # Raises an Error::Data exception if the given :key :value from :endpoint :data is not a positive number String instance.
            def check_key_value_is_positive_number_string_in_endpoint_data!(key:, value:, data:, endpoint:)
              raise_invalid_value_in_data(key: key, value: value, must_be: 'positive number as string', data: data, endpoint: endpoint) unless (value.is_a?(String) and value.to_i > 0)
            end

            # Raises an Error::Data exception if the given :key :value from :endpoint :data is not a specific :must_be value.
            def check_key_value_is_some_fix_value_in_endpoint_data!(key:, value:, data:, endpoint:, must_be:)
              raise_invalid_value_in_data(key: key, value: value, must_be: must_be, data: data, endpoint: endpoint) unless value == must_be
            end

            # Raises a Error::Data exception saying that the given :key from :endpoint :data is missing.
            #
            # @param key [String, Symbol] missing in data.
            # @param data [Object] where :key is missing.
            # @param endpoint [String, Symbol] naming the endpoint from where :data was received.
            def raise_missing_key_in_data(key:, data:, endpoint:)
              raise Error::Data.new(msg: "Got remote #{endpoint} data with missing #{key} key", data: data)
            end

            # Raises a Response::Error::Data exception saying that the given :key value from :endpoint :data is invalid.
            #
            # @param key [String, Symbol] whose value in data is invalid.
            # @param value [Object] invalid.
            # @param must_be [String] indicating the valid format for :key value.
            # @param data [Object] where :key value is invalid.
            # @param endpoint [String, Symbol] naming the endpoint from where :data was received.
            def raise_invalid_value_in_data(key:, value:, must_be:, data:, endpoint:)
              raise Error::Data.new(msg: "Got remote #{endpoint} data with invalid #{key} value (#{value}). Must be #{must_be}", data: data)
            end

        end


      end
    end
  end
end
