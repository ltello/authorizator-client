shared_context '#accessible:' do

  context '#accessible:' do
    let(:services_endpoint_path)    {'/services'}
    let(:valid_service1_name_value) {'service_one'}
    let(:valid_service2_name_value) {'service_two'}
    let(:valid_service1_site_value) {'https://service1.ideas4all.com'}
    let(:valid_service2_site_value) {'https://service2.ideas4all.com'}
    let(:valid_services_data)       {{'services' => [{'name' => valid_service1_name_value, 'site' => valid_service1_site_value},
                                                     {'name' => valid_service2_name_value, 'site' => valid_service2_site_value}]}}

    shared_examples "an invalid data response..." do |title|
      it title do
        allow(access_token).to receive(:get).with(services_endpoint_path).and_return(subject)
        allow(subject).to receive(:parsed).and_return(subject)
        expect {authorizator_client.services}.to raise_error(Authorizator::Client::Endpoints::Response::Error::Data)
      end
    end

    it 'returns true when the Autorizator host is reachable.' do
      allow(authorizator_client).to receive(:access_token).and_return(access_token)
      allow(access_token).to receive(:get).with(services_endpoint_path).and_return(valid_services_data)
      allow(valid_services_data).to receive(:parsed).and_return(valid_services_data)
      expect(authorizator_client).to             respond_to(:accessible?)
      expect(authorizator_client.accessible?).to be(true)
    end

    context 'And false in any other case:' do
      let(:blank_authorizator_service_site)       {""}
      let(:no_protocol_authorizator_service_site) {"localhost:3000"}
      let(:working_no_authorizator_service_site)  {"http://www.google.com"}

      it "- when the Authorizator's host url is blank?," do
        allow(authorizator_service).to receive(:site).and_return(blank_authorizator_service_site)
        expect(authorizator_client.accessible?).to be(false)
      end

      it "- when the Authorizator's host url has no protocol included," do
        allow(authorizator_service).to receive(:site).and_return(no_protocol_authorizator_service_site)
        expect(authorizator_client.accessible?).to be(false)
      end

      it "- when the Authorizator's host url is not the right one," do
        allow(authorizator_service).to receive(:site).and_return(working_no_authorizator_service_site)
        expect(authorizator_client.accessible?).to be(false)
      end

      it "- when the request to the Authorizator host raises any kind of exception." do
        allow(authorizator_service).to receive(:access_token).and_raise
        expect(authorizator_client.accessible?).to be(false)
      end
    end

  end

end
