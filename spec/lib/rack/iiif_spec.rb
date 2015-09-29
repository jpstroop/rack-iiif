require 'spec_helper.rb'
require 'rack/test'

describe 'middleware' do
  include ::Rack::Test::Methods

  let(:headers) { { header: 'value' } }
  let(:base_app) do
    double("Target Rack Application", :call => [200, headers, []])
  end

  let(:app) { described_class.new(base_app) }

  describe Rack::IIIF::Handler do
    describe '#call' do
      it 'returns a 200 status code' do
        get '/'
        expect(last_response.status).to eq 200
      end
      
      it 'retains headers' do
        get '/'
        expect(last_response.headers).to eq headers
      end
    end
  end

  describe Rack::IIIF::Router do
    describe '#call' do
      it { expect { get('/') }.not_to raise_error }
    end
  end
end
