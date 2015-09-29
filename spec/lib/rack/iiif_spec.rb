require 'spec_helper.rb'
require 'rack/test'

describe 'middleware' do
  include ::Rack::Test::Methods

  let(:headers) { { header: 'value' } }
  let(:base_app) do
    double("Target Rack Application", :call => [200, headers, []])
  end

  let(:app) { subject }

  describe Rack::IIIF::Handler do
    subject { described_class.new(base_app) }

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
    subject { described_class.new(base_app) }

    describe '#call' do
      describe 'info.json' do
        
        let(:id) { 'foo%2Fbar' }
        
        it 'recognizes info.json paths' do
          response = subject.call('PATH_INFO' => "/#{id}/info.json")

          expect(response.last.type).to eq :info
        end
      end
    end
  end
end
