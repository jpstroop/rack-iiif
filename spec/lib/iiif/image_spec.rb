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

  describe '#formats' do
    it 'is an array' do
      expect(subject.formats).to be_a Array
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

    context 'with supported format' do
      before { allow(subject).to receive(:formats).and_return([:jpg]) }
      
      let(:region) { double('region')  }
      let(:size) { double('size')  }
      let(:rotation) { double('rotation')  }
      let(:quality) { double('quality')  }

      it 'transcodes to supported format' do
        expect(subject.to_jpg(region, size, rotation, quality))
          .to respond_to(:read)
      end

      it 'knows it responds to supported format' do
        expect(subject).to respond_to(:to_jpg)
      end
    end
  end
end
