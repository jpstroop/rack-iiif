shared_examples 'a parameter' do
  subject { described_class.new(valids.first, *args) }

  it 'has a canonical value' do
    expect(subject.canonical_value).to be_a String
  end
  
  it 'validates for valid values' do
    valids.each do |valid|
      expect(described_class.new(valid, *args)).to be_valid
    end
  end

  it 'invalidates for invalid values' do
    invalids.each do |invalid|
      expect(described_class.new(invalid, *args)).not_to be_valid
    end
  end

  describe '#validate!' do
    it 'succeeds if valid' do
      valids.each do |valid|
        expect { described_class.new(valid, *args).validate! }
          .not_to raise_error 
      end
    end

    it 'raises an error if invalid' do
      invalids.each do |invalid|
        expect { described_class.new(invalid, *args).validate! }
          .to raise_error IIIF::RequestError
      end
    end
  end
end
