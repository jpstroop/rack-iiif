require 'spec_helper.rb'

describe IIIF::Resolver do
  describe '#resolve' do
    it 'is abstract' do
      expect { subject.resolve('abc') }.to raise_error NotImplementedError
    end
  end
end
