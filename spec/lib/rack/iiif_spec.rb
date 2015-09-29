require 'spec_helper.rb'
require 'rack/test'

describe Rack::IIIF do
  include ::Rack::Test::Methods

  let(:base_app) do
    double("Target Rack Application", :call => [200, {}, []])
  end

  let(:app) { described_class.new(base_app) }
  
  describe '#call' do
    it 'returns a 200 status code' do
      get '/'
      expect(last_response.status).to eq 200
    end
  end
end
