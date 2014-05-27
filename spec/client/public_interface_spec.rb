shared_context 'public interface' do

  describe 'Beside endpoints methods that return data from an associated endpoint, other method can be part of the public
            interface of a service client.' do
    let(:service_client_id)              {'12345'}
    let(:service_client_secret)          {'67890'}
    let(:service_class)                  {Struct.new(:client_id, :client_secret, :site)}
    let(:caller_service)                 {service_class.new(service_client_id, service_client_secret, nil)}
    let(:authorizator_service_site)      {'http://localhost:3000'}
    let(:authorizator_service)           {service_class.new(nil, nil, authorizator_service_site)}
    let(:authorizator_client)            {Authorizator::Client.new(caller_service:caller_service, authorizator_service:authorizator_service)}

    context 'The authorizator-client gem does not define no-endpoints public interface methods.' do
      it "However, any future one can be defined in the Authorizator::Client::PublicInterface module and will be
          available to the gem's calling software" do
        expect(authorizator_client).not_to respond_to(:new_public_interface_method)
        Authorizator::Client::PublicInterface.class_eval do
          define_method :new_public_interface_method do
            :in_new_public_interface_method
          end
        end
        expect(authorizator_client).to respond_to(:new_public_interface_method)
        expect(authorizator_client.new_public_interface_method).to eq(:in_new_public_interface_method)
      end
    end
  end

end
