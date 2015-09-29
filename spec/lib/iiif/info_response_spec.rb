require 'spec_helper.rb'

describe IIIF::InfoResponse do
  describe '#type' do
    it 'has type `:info`' do
      expect(subject.type).to eq :info
    end
  end

end
