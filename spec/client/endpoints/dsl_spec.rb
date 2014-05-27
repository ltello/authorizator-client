shared_context "dsl" do

  describe 'The following DSL helps the authorizator-client to define endpoints associated to the ones in the Authorizator service.' do
    let(:service_client_id)                  {'12345'}
    let(:service_client_secret)              {'67890'}
    let(:service_class)                      {Struct.new(:client_id, :client_secret, :site)}
    let(:caller_service)                     {service_class.new(service_client_id, service_client_secret, nil)}
    let(:authorizator_service_site)          {'http://localhost:3000'}
    let(:authorizator_service)               {service_class.new(nil, nil, authorizator_service_site)}
    let(:authorizator_client)                {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}
    let(:new_resource_endpoint_path)         {'/new_resource'}
    let(:new_resource_endpoint_another_path) {'/another_path_to/new_resource'}
    before(:each) do
    end

    context '.endpoint: the endpoint macro defines the path (relative to a service home url) where to access a protected resource.' do
      it 'To define an endpoint, you have to provide a pair (k,v) where k must be a symbol defining the endpoint name and
          v a string to act as endpoint path.' do
        expect {Authorizator::Client::Endpoints.endpoint(new_resource: new_resource_endpoint_path)}.not_to raise_error
      end

      it 'Automatically, a private method named after the name and "_endpoint" as suffix is available to be called to return the given endpoint path...' do
        expect(Authorizator::Client::Endpoints.private_instance_methods).to include(:new_resource_endpoint)
        expect(authorizator_client.send(:new_resource_endpoint)).to eq(new_resource_endpoint_path)
      end

      it "...or the path stated in the client's authorizator_service object if it overides the methodname and therefore the path." do
        allow(authorizator_service).to receive(:new_resource_endpoint).and_return(new_resource_endpoint_another_path)
        expect(authorizator_client.send(:new_resource_endpoint)).to be(new_resource_endpoint_another_path)
      end
    end
  end

end
