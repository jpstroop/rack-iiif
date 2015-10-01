require 'spec_helper.rb'

describe IIIF::TranscoderRegistry do
  let(:described_class) { Class.new(IIIF::TranscoderRegistry) }
  subject { described_class.instance }

  let(:transcoder) { double('transcoder') }

  describe '#all' do
    it 'is empty' do
      expect(subject.all).to be_empty
    end

    it 'has transcoders that have been added' do
      subject.add(transcoder)
      expect(subject.all).to contain_exactly(transcoder)
    end
  end

  describe '#add' do
    it 'adds a transcoder' do
      expect { subject.add(transcoder) }
        .to change { subject.all }
             .from([]).to(a_collection_containing_exactly(transcoder))
    end
    
    it 'sets up the transcoder formats'
  end
end
