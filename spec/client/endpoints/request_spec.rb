require 'spec_helper'

describe 'Requests to the Authorizator endpoints are made via an Authorizator::Client::Endpoints::AccessToken instance
          stored, accessed and renewed calling #access_token method and #maybe_renewing_access_token wrapper.' do
  let(:service_client_id)              {'12345'}
  let(:service_client_secret)          {'67890'}
  let(:service_class)                  {Struct.new(:client_id, :client_secret, :site)}
  let(:caller_service)                 {service_class.new(service_client_id, service_client_secret, nil)}
  let(:authorizator_service_site)      {'http://localhost:3000'}
  let(:authorizator_service)           {service_class.new(nil, nil, authorizator_service_site)}
  let(:authorizator_client)            {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}
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
    OAuth2::Client.stub(:new).and_return(new_client_application)
  end

  context '#access_token:' do
    it 'Before calling it for the first time, the store is empty.' do
      expect(authorizator_client.instance_variable_get(:@access_token)).to be_nil
    end

    context 'Calls to #access_token:' do
      let!(:first_authorizator_access_token_to_use)  {authorizator_client.send(:access_token)}

      it 'In the first call to #access_token method, a new Authorizator::Client::Endpoints::AccessToken is returned and
          stored to be used in subsequent calls.' do
        expect(authorizator_client.instance_variable_get(:@access_token)).not_to be_nil
      end

      it 'The next calls return the previously stored access token.' do
        expect {authorizator_client.send(:access_token)}.not_to change {authorizator_client.instance_variable_get(:@access_token)}
        expect {authorizator_client.send(:access_token)}.not_to change {authorizator_client.instance_variable_get(:@access_token)}
        expect(authorizator_client.send(:access_token)).to eq(authorizator_client.send(:access_token))
      end
    end
  end


  context '#maybe_renewing_access_token:
           Every request to the Authorizator endpoints (like access_token.get(any_endpoint,...)) should be wrapped in
           a call to #maybe_renewing_access_token to repeat the request in case the access_token used is not valid anymore
           (revoked, expired, invalid, ..., missing) and need to be automatically renewed (requested again to the Authorizator
           service).' do
    let(:valid_talking_token_value)  {'1234567890123456789012345678901234567890'}
    let(:talking_token_type)         {'bearer'}
    let(:talking_token_expires_in)   {'1000'}
    let(:talking_token_scope)        {'service_mate'}
    let(:valid_talking_token_data)   {{'access_token' => valid_talking_token_value,
                                       'token_type'   => talking_token_type,
                                       'expires_in'   => talking_token_expires_in,
                                       'scope'        => talking_token_scope}}
    let(:invalid_talking_token_data) {double(:error => double(:code => Authorizator::Client::Endpoints::Response::AUTHORIZATOR_SERVICE_INVALID_ACCESS_TOKEN_ERROR_CODES.first))}
    before(:each) do
      valid_talking_token_data.stub(:parsed).and_return(valid_talking_token_data)
    end

    it '#maybe_renewing_access_token executes the given block once...' do
      authorizator_client.send(:access_token).stub(:get).with('/services/talking_token').and_return(valid_talking_token_data)
      block = Proc.new {authorizator_client.send(:access_token).get(authorizator_client.send(:talking_token_endpoint))}
      authorizator_client.send(:maybe_renewing_access_token, &block)
      expect(authorizator_client.send(:access_token)).to have_received(:get).once
    end

    it '...unless the access token is invalid so it is called twice.' do
      calls_to_block = 0
      block = Proc.new do
        calls_to_block += 1
        authorizator_client.send(:access_token).stub(:get).with('/services/talking_token').and_return(invalid_talking_token_data)
        authorizator_client.send(:access_token).get(authorizator_client.send(:talking_token_endpoint))
      end
      expect {authorizator_client.send(:maybe_renewing_access_token, &block)}.to raise_error
      expect(calls_to_block).to eq(2)
    end

  end
end

