require 'spec_helper.rb'

describe IIIF do
end

shared_examples 'a RequestError' do
  describe '#status' do
    it { expect(subject.status).to be_a Integer }
  end

  describe '#headers' do
    it { expect(subject.headers).to be_a Hash }
  end

  describe '#message' do
    let(:message) { 'message' }

    it 'has assigned error message' do
      expect(described_class.new(message).message).to eq message
      
    end
  end
end

describe IIIF::RequestError do
  it_behaves_like 'a RequestError'
end

describe IIIF::BadRequest do
  it_behaves_like 'a RequestError'
end

describe IIIF::NotFound do
  it_behaves_like 'a RequestError'
end

describe IIIF::MethodNotAllowed do
  it_behaves_like 'a RequestError'
end
