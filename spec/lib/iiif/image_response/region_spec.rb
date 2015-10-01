describe IIIF::ImageResponse::Region do
  it_behaves_like 'a parameter' do
    let(:args) { [100, 100] }
    let(:valids) do
      ['1,2,3,4', 'pct:1,2,3,4', 'full', 'pct:0,0,100,100']
    end

    let(:invalids) do
      ['not_valid', 'pct:a,b,c,d', 'ful', 'a,b,c,d', '', '1,2,3'] 
    end
  end

  subject { described_class.new('1,2,3,4', 100, 100) }

  describe 'validate!' do
    it 'raises Not Implemented on `square`' do
      expect { described_class.new('square').validate! }
        .to raise_error IIIF::NotImplemented
    end
  end
  
  describe '#valid?' do
    it 'is not valid with silly percentages' do
      expect(described_class.new('pct:100,100,100,100', 101, 101))
        .not_to be_valid
    end

    it 'is not valid with oversized start point' do
      expect(described_class.new('110,110,100,100', 101, 101)).not_to be_valid
    end

    it 'is not valid with oversized start point percentage' do
      q = 'pct:105,105,100,100'
      expect(described_class.new(q, 101, 101)).not_to be_valid
    end
  end

  describe '#canonical' do
    it 'keep full when full' do
      expect(described_class.new('full').canonical_value).to eq 'full'
    end

    it 'x,y,w,h are formatted' do
      expect(subject.canonical_value).to eq '1,2,3,4'
    end

    it 'x,y,w,h are formatted with math(s)' do
      expect(described_class.new('100,100,100,100', 101, 101).canonical_value)
        .to eq '100,100,1,1'
    end

    it 'x,y,w,h are formatted when start point is overlarge' do
      expect(described_class.new('110,110,100,100', 101, 101).canonical_value)
        .to eq '110,110,0,0'
    end

    it 'x,y,w,h are formatted with percentage' do
      q = 'pct:50,50,100,100'
      expect(described_class.new(q, 101, 101).canonical_value)
        .to eq '50,50,51,51'
    end

    it 'x,y,w,h are formatted when percentage is 100 ' do
      q = 'pct:100,100,100,100'
      expect(described_class.new(q, 101, 101).canonical_value)
        .to eq '101,101,0,0'
    end

    it 'x,y,w,h are formatted when percentage is greater than 100' do
      q = 'pct:105,105,100,100'
      expect(described_class.new(q, 101, 101).canonical_value)
        .to eq '106,106,0,0'
    end
  end
  
  describe '#full?' do
    it 'is full when full' do
      expect(described_class.new('full')).to be_full
    end

    it 'is full when 0,0,max_w,max_h' do
      expect(described_class.new('0,0,100,100', 1, 1)).to be_full
    end
    
    it 'is full when pct:0,0,100,100' do
      expect(described_class.new('pct:0,0,100,100', 1, 1)).to be_full
    end

    it 'is full when super-full' do
      expect(described_class.new('pct:0,0,101,101', 1, 1)).to be_full
    end

    it 'is not full when not full' do
      expect(subject).not_to be_full
    end
  end

  describe '#pct?' do
    it 'is pct when pct' do
      expect(described_class.new('pct:0,0,10,10', 1, 1)).to be_pct
    end

    it 'is not pct when not pct' do
      expect(described_class.new('0,0,10,10', 1, 1)).not_to be_pct
    end

    it 'is not pct when full' do
      expect(described_class.new('pct:0,0,100,100', 1, 1)).not_to be_pct
    end

    it 'is not pct when super-full' do
      expect(described_class.new('pct:0,0,101,101', 1, 1)).not_to be_pct
    end
  end
end
