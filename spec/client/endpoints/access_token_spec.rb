require 'spec_helper'

describe "An access token is an object whose value must be included in the Authorization header of any request
          to the Authorizator service for it to give access to its protected resources (api) to external caller services." do

  context "Authorizator::Client::Endpoints::AccessToken: is the class representing obtained access tokens from the
           Authorizator Service:" do
    let(:service_client_id)              {'12345'}
    let(:service_client_secret)          {'67890'}
    let(:service_class)                  {Struct.new(:client_id, :client_secret, :site)}
    let(:caller_service)                 {service_class.new(service_client_id, service_client_secret, nil)}
    let(:authorizator_service_site)      {'http://localhost:3000'}
    let(:authorizator_service)           {service_class.new(nil, nil, authorizator_service_site)}
    let(:oauth_access_token_value)       {'567890123456789012345678901234567890'}
    let(:oauth_access_token_type)        {'bearer'}
    let(:oauth_access_token_expires_in)  {'500'}
    let(:oauth_access_token_scope)       {'myself'}
    let(:oauth_access_token_data)        {{'access_token' => oauth_access_token_value,
                                           'token_type'   => oauth_access_token_type,
                                           'expires_in'   => oauth_access_token_expires_in,
                                           'scope'        => oauth_access_token_scope}}
    let(:oauth_access_token)             {OAuth2::AccessToken.from_hash(new_client_application, oauth_access_token_data)}
    let(:new_client_application)         {double(:request => nil)}
    let(:access_token)                   {Authorizator::Client::Endpoints::AccessToken.new(caller_service:       caller_service,
                                                                                           authorizator_service: authorizator_service)}

    before(:each) do
      new_client_application.stub(:client_credentials => double(:get_token => oauth_access_token))
    end

    context "- Instantiation:" do
      it "To create an Authorizator::Client::Endpoints::AccessToken instance you must provide two objects: <caller_service> and <authorizator_service>" do
        OAuth2::Client.stub(:new).and_return(new_client_application)
        expect(access_token).to be_an(Authorizator::Client::Endpoints::AccessToken)
      end

      it "<caller_service> object must respond to #client_id..." do
        invalid_service_class = Struct.new(:client_secret, :site)
        caller_service        = invalid_service_class.new(service_client_secret, 'http://localhost:3001')
        expect{Authorizator::Client::Endpoints::AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end

      it "and #client_secret." do
        invalid_service_class = Struct.new(:client_id, :site)
        caller_service        = invalid_service_class.new(service_client_id, 'http://localhost:3001')
        expect{Authorizator::Client::Endpoints::AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end

      it "<authorizator_service> object must respond to #site." do
        invalid_service_class = Struct.new(:client_id, :client_secret)
        authorizator_service  = invalid_service_class.new(service_client_id, service_client_secret)
        expect{Authorizator::Client::Endpoints::AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end

      it "An invalid access token error is raised if no remote access token can be obtained..." do
        invalid_client_application = double(:client_credentials => double(:get_token => nil))
        OAuth2::Client.stub(:new).and_return(invalid_client_application)
        expect{Authorizator::Client::Endpoints::AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error(Authorizator::Client::Endpoints::Response::Error::AccessToken)
      end

      it "... or a void one is received." do
        invalid_client_application = double(:client_credentials => double(get_token: double(token: "", params: {p1: "p1-value"}, to_hash: {})))
        OAuth2::Client.stub(:new).and_return(invalid_client_application)
        expect{Authorizator::Client::Endpoints::AccessToken.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error(Authorizator::Client::Endpoints::Response::Error::AccessToken, /p1-value/)
      end
    end

    context "- Interface" do
      before(:each) do
        OAuth2::Client.stub(:new).and_return(new_client_application)
      end

      context "#caller_service" do
        it "returns an object representing the service accessing the Authorizator" do
          expect(access_token.caller_service).to eq(caller_service)
        end
      end

      context "#authorizator_service" do
        it "returns an object representing the Authorizator service" do
          expect(access_token.authorizator_service).to eq(authorizator_service)
        end
      end

      context "The following methods are provided to make requests to the Authorizator service endpoints.
               To do that, the processing is forwarded to an OAuth2::Client instance.
               See its documentation for a list of opts allowed (:params, :body...) and the use of the &block:" do

        it "#headers:
            returns the Authorization header to be sent in every request to the Authorizator." do
            expect(access_token.headers).to eq({"Authorization" => "Bearer #{oauth_access_token_value}"})
        end

        it "#get(endpoint_relative_path, opts={}, &block):
            makes a <get> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the access token's token value" do
            access_token.get('/path_to_authorizator_endpoint', params: {id:7})
            expect(new_client_application).to have_received(:request).with(:get, '/path_to_authorizator_endpoint', {params: {id:7}}.merge!(headers: access_token.headers)).once
        end

        it "#post(endpoint_relative_path, opts={}, &block):
            makes a <post> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the access token's token value" do
            access_token.post('/path_to_authorizator_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:post, '/path_to_authorizator_endpoint', {body: {id:7}}.merge!(headers: access_token.headers)).once
        end

        it "#put(endpoint_relative_path, opts={}, &block):
            makes a <put> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the access token's token value" do
            access_token.put('/path_to_authorizator_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:put, '/path_to_authorizator_endpoint', {body: {id:7}}.merge!(headers: access_token.headers)).once
        end

        it "#patch(endpoint_relative_path, opts={}, &block):
            makes a <patch> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the access token's token value" do
            access_token.patch('/path_to_authorizator_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:patch, '/path_to_authorizator_endpoint', {body: {id:7}}.merge!(headers: access_token.headers)).once
        end

        it "#delete(endpoint_relative_path, opts={}, &block):
            makes a <delete> request to the Authorizator service endpoint in <endpoint_relative_path> passing the given <opts>
            and including <Authorization header> with the access token's token value" do
            access_token.delete('/path_to_authorizator_endpoint', body: {id:7})
            expect(new_client_application).to have_received(:request).with(:delete, '/path_to_authorizator_endpoint', {body: {id:7}}.merge!(headers: access_token.headers)).once
        end
      end

    end
  end
end
