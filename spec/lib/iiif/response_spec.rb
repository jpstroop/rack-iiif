require 'spec_helper.rb'

describe IIIF::Response do
  it { is_expected.to be_a described_class }

  describe '#type' do
    it 'raises not implemented for abstract' do
      expect { subject.type }.to raise_error NotImplementedError
    end
  end
end
