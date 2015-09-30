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

      context 'with HTTP error' do
        before { allow(base_app).to receive(:call).and_raise(error_class) }
        let(:error_class) { IIIF::RequestError }
        
        it 'returns an error status' do
          get '/'
          expect(last_response.status).to eq error_class::STATUS
        end

        it 'returns message status' do
          get '/'
          expect(last_response.body).to eq error_class.new.message
        end
      end
    end
  end

  describe Rack::IIIF::Router do
    subject { described_class.new(base_app) }

    describe '#call' do
      let(:ids) { ['foo', 'foo%2Fbar'] }

      shared_examples 'info responses' do 
        it 'recognizes info.json paths' do
          paths.each do |path|
            response = subject.call('PATH_INFO' => path)
            expect(response.last.type).to eq :info
          end
        end

        it 'gives response with correct id' do
          paths.each_with_index do |path, idx|
            response = subject.call('PATH_INFO' => path)
            expect(response.last.id).to eq ids[idx]
          end
        end
      end

      describe 'base uri' do
        include_examples 'info responses' do
          let(:paths) { ids.map { |id| "/#{id}" } }
        end
      end

      describe 'info.json' do
        include_examples 'info responses' do
          let(:paths) { ids.map { |id| "/#{id}/info.json" } }
        end
      end

      describe 'not info.json' do
        it 'does not give an info response' do
          expect(subject.call('PATH_INFO' => "/#{ids.first}/blah/blah").last)
            .not_to be_a ::IIIF::InfoResponse
        end
      end
    end
  end
end
