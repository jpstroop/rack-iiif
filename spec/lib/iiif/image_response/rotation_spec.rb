describe IIIF::ImageResponse::Rotation do
  it_behaves_like 'a parameter' do
    let(:args) { [] }
    let(:valids) { ['0', '!0', '!180', '!180', '360', '!360', '0.1', '!0.1'] }
    let(:invalids) { ['361', '!361', '360.1', '!360.1', '-1', '!-1', 'a39'] }
  end

  subject { described_class.new('90') }

  describe '#canonical_value' do
    it 'gives int version if no decimal values' do
      expect(subject.canonical_value).to eq '90'
    end

    it 'gives int version if decimal values is .0' do
      expect(described_class.new('90.0').canonical_value).to eq '90'
    end

    it 'gives float version if decimal values are present' do
      expect(described_class.new('90.1').canonical_value).to eq '90.1'
    end

    it 'gives mirror character if decimal values are present' do
      expect(described_class.new('!90.1').canonical_value).to eq '!90.1'
    end

    it 'has a system precision float cap' do
      value = '90.1111111111111111111111111111'
      expect(described_class.new(value).canonical_value).to eq value.to_f.to_s
    end
  end

  describe '#in_range?' do
    it 'is in range for values between 0 and 360' do
      ['0', '0.1', '90', '360'].each do |val|
        expect(described_class.new(val)).to be_in_range
      end
    end

    it 'is out of range for other values' do
      ['-1', '-0.1', '900', '360.1'].each do |val|
        expect(described_class.new(val)).not_to be_in_range
      end
    end
  end

  describe '#rotation' do
    it 'gives nil when no match' do
      expect(described_class.new('moomin').rotation).to be_nil
    end

    it 'gives rotation as float with match' do
      expect(described_class.new('360').rotation).to eql 360.0
    end

    it 'gives rotation as float with mirrored match' do
      expect(described_class.new('!360').rotation).to eql 360.0
    end
  end

  describe '#mirror?' do
    it 'gives false when no match' do
      expect(described_class.new('moomin')).not_to be_mirror
    end

    it 'gives false when mirror char is not present' do
      expect(described_class.new('360')).not_to be_mirror
    end

    it 'gives true when mirror char is present' do
      expect(described_class.new('!360')).to be_mirror
    end
  end
end
