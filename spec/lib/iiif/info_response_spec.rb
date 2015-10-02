require 'spec_helper.rb'

describe IIIF::InfoResponse do
  it_behaves_like 'a response'

  subject { described_class.new(id: ident) }

  let(:ident) { 'foo%2Fbar' }

  describe '#type' do
    it 'has type `:info`' do
      expect(subject.type).to eq :info
    end
  end

  describe '#id' do
    it 'returns the id string' do
      expect(subject.id).to eq ident
    end
  end
end
