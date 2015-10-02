shared_examples 'a response' do
  describe '#to_response' do
    it 'looks like a Rack response' do
      expect(subject.to_response)
        .to contain_exactly(a_kind_of(Integer),
                            an_instance_of(Hash),
                            respond_to(:each))
    end

    it 'retains headers passed in' do
      headers = { 'KeepMe' => 'Moomin', 'OverwriteMe' => 'MoominPapa' }
      subject.headers = { 'OverwriteMe' => 'MoominMama' }
      
      expect(subject.to_response(headers)[1])
        .to eq({ 'KeepMe' => 'Moomin', 'OverwriteMe' => 'MoominMama' })
    end

    it 'has a type (or is not implemented)' do
      if described_class == IIIF::Response
        expect { subject.type }.to raise_error NotImplementedError
      else
        expect(subject.type).to be_a Symbol
      end
    end
  end
end

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
