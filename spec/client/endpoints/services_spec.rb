shared_context '#services:' do

  context '#services:' do
    let(:services_endpoint_path) {'/services'}
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

    it 'returns a list of ideas4all services data secured by the Authorizator service.' do
      allow(access_token).to receive(:get).with(services_endpoint_path).and_return(valid_services_data)
      allow(valid_services_data).to receive(:parsed).and_return(valid_services_data)
      expect(authorizator_client).to                 respond_to(:services)
      expect(authorizator_client.private_methods).to include(:services_endpoint)
      expect(authorizator_client.services).to        eq(valid_services_data['services'])
    end

    context 'The hash returned contains, at least data for the services list:' do
      it_behaves_like "an invalid data response...", "...unless has a 'services' key." do
        subject {valid_services_data.dup.tap {|h| h.delete('services')}}
      end

      it_behaves_like "an invalid data response...", "...unless has an array as value for 'services' key." do
        subject {valid_services_data.merge('services' => {})}
      end
    end

    context 'Every element of the array (service data) contains identification data of the service:' do
      it_behaves_like "an invalid data response...", "...unless the element has a 'name' key." do
        subject {valid_services_data.dup.tap {|h| h['services'].first.delete('name')}}
      end

      it_behaves_like "an invalid data response...", "...unless the element has a no empty string as value for the 'name' key." do
        subject {valid_services_data.dup.tap {|h| h['services'].first['name'] = ''}}
      end
    end

    context 'Every service data contains location data of the service:' do
      it_behaves_like "an invalid data response...", "...unless the element has a 'site' key." do
        subject {valid_services_data.dup.tap {|h| h['services'].first.delete('site')}}
      end

      it_behaves_like "an invalid data response...", "...unless the element has a no empty string as value for the 'site' key." do
        subject {valid_services_data.dup.tap {|h| h['services'].first['site'] = ''}}
      end
    end
  end

end
