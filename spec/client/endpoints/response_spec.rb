shared_context "response" do

  describe 'The response of the Authorizator to a request to access its api, differs depending on the request,
            the attached access_token, etc. These private methods return info about a received response:' do
    let(:service_client_id)                        {'12345'}
    let(:service_client_secret)                    {'67890'}
    let(:service_class)                            {Struct.new(:client_id, :client_secret, :site)}
    let(:caller_service)                           {service_class.new(service_client_id, service_client_secret, nil)}
    let(:authorizator_service_site)                {'http://localhost:3000'}
    let(:authorizator_service)                     {service_class.new(nil, nil, authorizator_service_site)}
    let(:authorizator_client)                      {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}
    let(:random_string_1)                          {8.times.map {|t| rand(255).chr}.join}
    let(:random_string_2)                          {3.times.map {|t| rand(255).chr}.join}
    let(:invalid_access_token_error_codes)         {Authorizator::Client::Endpoints::Response::AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES}
    let(:no_http_response)                         {double}
    let(:invalid_access_token_header_response)     {double(:error => double(:code => 7), :headers => {'www-authenticate' => (random_string_1 + invalid_access_token_error_codes.first + random_string_2)})}
    let(:no_error_responding_response)             {double(:headers => {})}
    let(:error_blank_response)                     {double(:headers => {}, :error => nil)}
    let(:invalid_access_token_error_code_response) {double(:headers => {}, :error => double(:code => invalid_access_token_error_codes.first))}
    let(:no_invalid_access_token_error_response)   {double(:headers => {}, :error => double(:code => 7))}

    context '#invalid_access_token_response?(resp):' do
      it 'does not check the response headers if the response object dont respond to #headers.' do
        allow(Regexp).to receive(:new).and_return(nil)
        authorizator_client.send(:invalid_access_token_response?, no_http_response)
        expect(Regexp).not_to have_received(:new)
      end

      it 'If it does, checks the response headers looking for an error condition (in www-authenticate header right now).' do
        expect(invalid_access_token_error_codes).to include(authorizator_client.send(:invalid_access_token_response?, invalid_access_token_header_response))
      end

      it 'returns false when the response do not respond to #error...' do
        expect(authorizator_client.send(:invalid_access_token_response?, no_error_responding_response)).to be_falsey
      end

      it '... or the error object is present.' do
        expect(authorizator_client.send(:invalid_access_token_response?, error_blank_response)).to be_falsey
      end

      it 'Returns the error code when the response.error.code is one of the invalid access token ones...' do
        expect(invalid_access_token_error_codes).to include(authorizator_client.send(:invalid_access_token_response?, invalid_access_token_error_code_response))
      end

      it 'In any other case, invalid_access_token_response? should be false' do
        expect(authorizator_client.send(:invalid_access_token_response?, no_invalid_access_token_error_response)).to be_falsey
      end
    end
  end

end
