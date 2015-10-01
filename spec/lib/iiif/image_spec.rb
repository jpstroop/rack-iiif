require 'spec_helper.rb'

describe IIIF::Image do
  subject { described_class.new(path, source_format) }
  
  let(:path) { 'path/to/file.jpg' }
  let(:source_format) { :jpg }
  
  describe '#path' do
    it 'is the path' do
      expect(subject.path).to eq path
    end
  end

  describe '#source_format' do
    it 'is the source format' do
      expect(subject.source_format).to eq source_format
    end
  end

  describe '#info' do
    let(:info) { double('image info') }

    it 'can be set on initialization' do
      image = described_class.new(path, source_format, info: info)
      expect(image.info).to eq info
    end

    it 'extracts its own image info' do
      extractor = double('ExtractorModule', extract: info)
      image = described_class.new(path, source_format, extractor: extractor)
      
      expect(image.info).to eq info
    end
  end

  describe '#to_*' do
    it 'raises method undefined for unsupported formats' do
      expect { subject.to_nonsense }.to raise_error NoMethodError
    end

    it 'transcodes to supported format' do
      allow(subject).to receive(:formats).and_return([:jpg])
      region, size, rotation, quality = [double, double, double, double]
      
      expect(subject.to_jpg(region, size, rotation, quality))
        .to respond_to(:read)
    end
  end
end
