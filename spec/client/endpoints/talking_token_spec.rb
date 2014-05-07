require 'spec_helper'

shared_context '#talking_token:' do
  context '#talking_token:' do
    let(:talking_token_endpoint_path) {'/services/talking_token'}
    let(:valid_talking_token_value)   {'1234567890123456789012345678901234567890'}
    let(:talking_token_type)          {'bearer'}
    let(:talking_token_expires_in)    {1000}
    let(:talking_token_scope)         {'service_mate'}
    let(:valid_talking_token_data)    {{'access_token' => valid_talking_token_value,
                                        'token_type'   => talking_token_type,
                                        'expires_in'   => talking_token_expires_in,
                                        'scope'        => talking_token_scope}}

    shared_examples "an invalid data response..." do |title|
      it title do
        allow_message_expectations_on_nil
        access_token.stub(:get).with(talking_token_endpoint_path).and_return(subject)
        subject.stub(:parsed).and_return(subject)
        expect {authorizator_client.talking_token}.to raise_error(Authorizator::Client::Endpoints::Response::Error::Data)
      end
    end

    it 'returns valid token data for the ideas4all services to be able to talk to each other.' do
      access_token.stub(:get).with(talking_token_endpoint_path).and_return(valid_talking_token_data)
      valid_talking_token_data.stub(:parsed).and_return(valid_talking_token_data)
      expect(authorizator_client).to                 respond_to(:talking_token)
      expect(authorizator_client.private_methods).to include(:talking_token_endpoint)
      expect(authorizator_client.talking_token).to   eq(valid_talking_token_data)
    end

    it_behaves_like "an invalid data response...", "...unless the data returned is a Hash instance." do
      subject {}
    end

    context 'The hash returned contains, at least data for the token itself:' do
      it_behaves_like "an invalid data response...", "...unless has an 'access_token' key." do
        subject {valid_talking_token_data.dup.tap {|h| h.delete('access_token')}}
      end

      it_behaves_like "an invalid data response...", "...unless has a no empty string as value for 'access_token' key." do
        subject {valid_talking_token_data.merge('access_token' => '')}
      end
    end

    context 'The hash returned also contains data for the token type...' do
      it_behaves_like "an invalid data response...", "...unless has an 'token_type' key." do
        subject {valid_talking_token_data.dup.tap {|h| h.delete('token_type')}}
      end

      it_behaves_like "an invalid data response...", "...unless has 'bearer' as value for 'token_type' key." do
        subject {valid_talking_token_data.merge('token_type' => 'no_bearer')}
      end
    end

    context 'The hash returned also contains expiration data...' do
      it_behaves_like "an invalid data response...", "...unless has an 'expires_in' key." do
        subject {valid_talking_token_data.dup.tap {|h| h.delete('expires_in')}}
      end

      it_behaves_like "an invalid data response...", "...unless has a fixnum with a positive number of seconds to expire as value for 'expires_in' key." do
        subject {valid_talking_token_data.merge('expires_in' => nil)}
      end
    end

    context 'The hash returned also contains token scope info...' do
      it_behaves_like "an invalid data response...", "...unless has an 'scope' key." do
        subject {valid_talking_token_data.dup.tap {|h| h.delete('scope')}}
      end

      it_behaves_like "an invalid data response...", "...unless has 'service_mate' as value for 'scope' key." do
        subject {valid_talking_token_data.merge('scope' => 'no_service_mate')}
      end
    end
  end
end


