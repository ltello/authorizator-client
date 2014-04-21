require 'spec_helper'
require 'client/endpoints/talking_token_spec'
require 'client/endpoints/services_spec'

describe 'Endpoints are the urls where a service exposes resources (api). A service client make http requests to these
          paths to interact with the service api.' do
  let(:service_client_id)              {'12345'}
  let(:service_client_secret)          {'67890'}
  let(:service_class)                  {Struct.new(:client_id, :client_secret, :site)}
  let(:caller_service)                 {service_class.new(service_client_id, service_client_secret, nil)}
  let(:authorizator_service_site)      {'http://localhost:3000'}
  let(:authorizator_service)           {service_class.new(nil, nil, authorizator_service_site)}
  let(:authorizator_client)            {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}
  let(:access_token)                   {double}
  before(:each) do
    authorizator_client.stub(:access_token).and_return(access_token)
  end

  context 'The authorizator-client gem exposes the following methods to access the corresponding Authorizator service endpoints:' do
    include_context '#talking_token:'
    include_context '#services:'
  end

end
