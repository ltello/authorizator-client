require 'client/endpoints_spec'
require 'client/public_interface_spec'
require 'client/endpoints/request_spec'
require 'client/endpoints/access_token_spec'
require 'client/endpoints/dsl_spec'
require 'client/endpoints/response_spec'


shared_context "client:" do

  describe "Authorizator::Client: the Authorizator service api resources are provided via this class." do
    let(:valid_service_client_id)     {'12345'}
    let(:valid_service_client_secret) {'67890'}
    let(:service_class)               {Struct.new(:client_id, :client_secret, :site)}
    let(:caller_service)              {service_class.new(valid_service_client_id, valid_service_client_secret, nil)}
    let(:authorizator_service_site)   {'http://localhost:3000'}
    let(:authorizator_service)        {service_class.new(nil, nil, authorizator_service_site)}
    let(:authorizator_client)         {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}
    let(:valid_access_token_value)    {'567890123456789012345678901234567890'}
    let(:access_token_type)           {'bearer'}
    let(:access_token_expires_in)     {500}
    let(:access_token_scope)          {'myself'}
    let(:valid_access_token_data)     {{'access_token' => valid_access_token_value,
                                        'token_type'   => access_token_type,
                                        'expires_in'   => access_token_expires_in,
                                        'scope'        => access_token_scope}}
    let(:valid_access_token)          {Authorizator::Client::Endpoints::AccessToken.from_hash(nil, valid_access_token_data)}
    let(:valid_talking_token_value)   {'1234567890123456789012345678901234567890'}
    let(:talking_token_type)          {'bearer'}
    let(:talking_token_expires_in)    {1000}
    let(:talking_token_scope)         {'service_mate'}
    let(:valid_talking_token_data)    {{'access_token' => valid_talking_token_value,
                                        'token_type'   => talking_token_type,
                                        'expires_in'   => talking_token_expires_in,
                                        'scope'        => talking_token_scope}}
    let(:new_client_application)      {double(:client_credentials => double(:get_token => valid_access_token))}

    context "- Instantiation:" do
      it "To create an Authorizator::Client instance you must provide two objects: <caller_service> and <authorizator_service>" do
        expect(authorizator_client).to be_an(Authorizator::Client)
      end

      it "An error will be raised otherwise." do
        expect {Authorizator::Client.new}.to raise_error
        expect {Authorizator::Client.new(caller_service: caller_service)}.to raise_error(ArgumentError)
        expect {Authorizator::Client.new(authorizator_service: authorizator_service)}.to raise_error(ArgumentError)
      end

      it "<caller_service> object must respond to #client_id..." do
        invalid_service_class = Struct.new(:client_secret, :site)
        caller_service        = invalid_service_class.new(valid_service_client_secret, 'http://localhost:3001')
        expect {Authorizator::Client.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end

      it "and #client_secret." do
        invalid_service_class = Struct.new(:client_id, :site)
        caller_service        = invalid_service_class.new(valid_service_client_id, 'http://localhost:3001')
        expect {Authorizator::Client.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end

      it "<authorizator_service> object must respond to #site." do
        invalid_service_class = Struct.new(:client_id, :client_secret)
        authorizator_service  = invalid_service_class.new(valid_service_client_id, valid_service_client_secret)
        expect {Authorizator::Client.new(caller_service: caller_service, authorizator_service: authorizator_service)}.to raise_error
      end
    end

    context "- Interface" do

      context "#caller_service" do
        it "returns an object representing the service accessing the Authorizator" do
          expect(authorizator_client.caller_service).to eq(caller_service)
        end
      end

      context "#authorizator_service" do
        it "returns an object representing the Authorizator service" do
          expect(authorizator_client.authorizator_service).to eq(authorizator_service)
        end
      end

      context "#talking_token: every pair of ideas4all services need a talking token to be able to communicate each other.
               This token is returned by the Authorizator service only to its previously registered services." do
        it "returns a hash with talking token data, including :access_token, :token_type, :expires_in, :scope.
            Run tests in client/endpoints_spec for detailed info." do
          expect(authorizator_client).to respond_to(:talking_token)
        end
      end

      context "#services: the Authorizator api offers a list of ideas4all services that it secures." do
        it "returns a list of the form: {services: [{name: 'service1', site: 'https://..'}, ... ,{}]}.
            Run tests in client/endpoints_spec for detailed info." do
          expect(authorizator_client).to respond_to(:services)
        end
      end
    end

    include_context 'endpoints'
    include_context 'public interface'
    include_context 'request'
    include_context 'access token'
    include_context 'dsl'
    include_context 'response'

  end

end
