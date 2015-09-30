require 'spec_helper.rb'
require 'rack/test'

describe 'middleware' do
  include ::Rack::Test::Methods

  let(:headers) { { header: 'value' } }
  let(:body) { [] }

  let(:base_app) do
    double("Target Rack Application", :call => [200, headers, body])
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

      context 'with a RedirectResponse' do
        let(:uri_target) { 'http://ex.org/moomin' }
        let(:body) { IIIF::RedirectResponse.new(uri_target) }
        let(:headers) { { header: 'value', 'Location' => 'moomin' } }

        it 'gives redirect status code' do
          get '/'
          expect(last_response.status).to eq body.status
        end

        it 'gives target in location header' do
          get '/'
          expect(last_response.headers['Location']).to eq uri_target
        end

        it 'retains existing headers' do
          get '/'
          expect(last_response.headers[:header]).to eq headers[:header]
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
        it 'gives redirect response' do
          expect(subject.call('PATH_INFO' => "/moomin").last)
            .to be_a IIIF::RedirectResponse
        end

        it 'redirects to `info.json`' do
          ['/moomin', '/moomin/'].each do |path|
            expect(subject.call('PATH_INFO' => path).last.target)
              .to end_with '/moomin/info.json'
          end
        end
      end

      describe 'info.json' do
        include_examples 'info responses' do
          let(:paths) { ids.map { |id| "/#{id}/info.json" } }
        end
      end

      describe 'image response' do
        let(:path) do
          "#{id}/#{region}/#{size}/#{rotation}/#{quality}.#{format}"
        end

        let(:id) { 'moomin' }
        let(:region) { 'full' }
        let(:size) { 'full' }
        let(:rotation) { '0' }
        let(:quality) { 'default' }
        let(:format) { 'jpg' }

        it 'is an image response' do
          expect(subject.call('PATH_INFO' => path).last)
            .to be_a ::IIIF::ImageResponse
        end

        [:id, :region, :size, :rotation, :quality, :format].each do |p|
          it "sets the #{p}" do
            expect(subject.call('PATH_INFO' => path).last.send(p)).not_to be_nil
          end
        end
      end

      describe 'nonsense request' do
        it 'does not give an info response' do
          expect(subject.call('PATH_INFO' => "/#{ids.first}/blah/blah").last)
            .not_to be_a ::IIIF::InfoResponse
        end

        it 'does not give an image response' do
          expect(subject.call('PATH_INFO' => "/#{ids.first}/blah/blah").last)
            .not_to be_a ::IIIF::ImageResponse
        end
      end
    end
  end
end
