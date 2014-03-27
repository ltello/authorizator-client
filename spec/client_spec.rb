require 'spec_helper'

describe "The authorizator-client gem is the Ruby client to give access to the ideas4all's Authorizator service to other services. It:
              - gives the caller access to the Authorizator service's api through common Ruby modules, classes and methods.
              - communicates with the Authorizator service's api via the OAuth2 protocol,
              - take care of security concerns in a transparent way to the caller,
              - parse responses and return plain Ruby objects from the http json responses." do

  context "Authorizator::Client: the Authorizator service api resources are provided via this class." do
    let(:valid_service_client_id)     {'12345'}
    let(:valid_service_client_secret) {'67890'}
    let(:valid_service_credentials)   {{:client_id     => valid_service_client_id,
                                        :client_secret => valid_service_client_secret}}
    let(:authorizator_client)         {Authorizator::Client.new(valid_service_credentials)}

    context "- Instantiation:" do
      it "To create an Authorizator::Client instance you must provide at least two option params: :client_id and :client_secret" do
        expect(authorizator_client).to be_an(Authorizator::Client)
      end

      it "An error will be raised otherwise" do
        expect{Authorizator::Client.new}.to raise_error
      end
    end

    context "- Interface" do
      context "#service_credentials" do
        it "returns a hash with keys :client_id and :client_secret corresponding to the service accessing the Authorizator" do
          expect(authorizator_client.service_credentials).to eq(valid_service_credentials)
        end
      end

      context "#talking_token: every pair of ideas4all services need a talking token to be able to communicate each other.
                              This token is returned by the Authorizator service only to its previously registered services." do
        context "   When called for the first time..." do
          let(:authorizator_service_site)   {Authorizator::Client::AUTHORIZATOR_SERVICE_SITE}
          let(:valid_access_token_value)    {'567890123456789012345678901234567890'}
          let(:access_token_type)           {'bearer'}
          let(:access_token_expires_in)     {'500'}
          let(:access_token_scope)          {'myself'}
          let(:valid_access_token_data)     {{'access_token' => valid_access_token_value,
                                              'token_type'   => access_token_type,
                                              'expires_in'   => access_token_expires_in,
                                              'scope'        => access_token_scope}}
          let(:valid_talking_token_value)   {'1234567890123456789012345678901234567890'}
          let(:talking_token_type)          {'bearer'}
          let(:talking_token_expires_in)    {'1000'}
          let(:talking_token_scope)         {'service_mate'}
          let(:valid_talking_token_data)    {{'access_token' => valid_talking_token_value,
                                              'token_type'   => talking_token_type,
                                              'expires_in'   => talking_token_expires_in,
                                              'scope'        => talking_token_scope}}
          # let(:valid_service_client_id)     {'12345'}
          # let(:valid_service_client_secret) {'67890'}
          # let(:valid_service_credentials)   {{:client_id     => valid_service_client_id,
          #                                    :client_secret => valid_service_client_secret}}
          let(:new_client_application)      {double(:client_credentials => double(:get_token => valid_access_token_data))}

          before(:each) do
            authorizator_client.stub(:new_client_application).and_return(new_client_application)
            valid_access_token_data.stub(:get).and_return(valid_talking_token_data)
            valid_talking_token_data.stub(:parsed).and_return(valid_talking_token_data)
          end

          it "... a new oauth2 client instance to be able to reach the Authorizator service api is created and stored." do
            authorizator_client.talking_token
            client_application_cache = authorizator_client.instance_variable_get(:@client_application)
            expect(authorizator_client).to have_received(:new_client_application)
            expect(client_application_cache).not_to be_nil
          end
        end

      end
    end
  end
end
