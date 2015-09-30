require 'spec_helper.rb'

describe IIIF::RedirectResponse do
  subject { described_class.new(target, status) }
  
  let(:target) { 'http://example.org/moomin' }
  let(:status) { 303 }
  
  describe '#target' do
    it 'is the target URI' do
      expect(subject.target).to eq target
    end
  end

  describe '#status' do
    it 'is the status code' do
      expect(subject.status).to eq status
    end

    it 'defaults to 303' do
      expect(described_class.new(target).status).to eq 303
    end
  end
end
