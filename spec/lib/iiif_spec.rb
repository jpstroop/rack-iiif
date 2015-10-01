require 'spec_helper.rb'

describe IIIF do
  describe '#configure' do
    it 'yields self' do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(IIIF::Configuration.instance)
    end
  end
end

describe IIIF::Configuration do
  after { subject.reset! }

  subject { described_class.instance }
  let(:resolver) { double('resolver') }

  describe '#add_resolver' do
    it 'adds a resolver' do
      expect { subject.add_resolver(:sym, resolver) }.to change { subject.resolvers }.to include(:sym)
    end
  end

  describe '#resolvers' do
    it 'is empty' do
      expect(subject.resolvers).to be_empty
    end

    it 'has resolver' do
      subject.add_resolver(:sym, resolver)
      
      expect(subject.resolvers[:sym]).to eq resolver
    end
  end
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
