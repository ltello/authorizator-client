require 'spec_helper'

describe 'Endpoints are the urls where a service exposes resources (api). A service client make http requests to these
          paths to interact with the service api.' do
  let(:service_client_id)              {'12345'}
  let(:service_client_secret)          {'67890'}
  let(:service_class)                  {Struct.new(:client_id, :client_secret, :site)}
  let(:caller_service)                 {service_class.new(service_client_id, service_client_secret, nil)}
  let(:authorizator_service_site)      {'http://localhost:3000'}
  let(:authorizator_service)           {service_class.new(nil, nil, authorizator_service_site)}
  let(:authorizator_client)            {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}

  context 'The authorizator-client gem must define and expose the following methods to access the Authorizator service endpoints:' do
    context '#talking_token:' do
      it 'returns a hash with the data valid for the ideas4all services to talk to each other' do
        expect(authorizator_client).to respond_to(:talking_token)
        expect(authorizator_client.private_methods).to include(:talking_token_endpoint)
      end
    end

    context '#services:' do
      it 'returns a list of ideas4all services data' do
        expect(authorizator_client).to respond_to(:services)
        expect(authorizator_client.private_methods).to include(:services_endpoint)
      end
    end
  end

end
