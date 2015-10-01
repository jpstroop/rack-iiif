require 'spec_helper.rb'

describe IIIF::ImageResponse do
  subject do
    described_class.new(id:       id,
                        region:   region,
                        size:     size,
                        rotation: rotation,
                        quality:  quality,
                        format:   format)
  end

  let(:id) { 'moomin' }
  let(:region) { 'full' }
  let(:size) { 'full' }
  let(:rotation) { '0' }
  let(:quality) { 'default' }
  let(:format) { 'jpg' }

  describe '#region=' do
    it 'converts to region value' do
      expect { subject.region = 'moomin' }.to change { subject.region }.to an_instance_of IIIF::ImageResponse::Region
    end
  end

  describe '#rotation=' do
    it 'converts to rotation value' do
      expect { subject.rotation = 'moomin' }.to change { subject.rotation }.to an_instance_of IIIF::ImageResponse::Rotation
    end
  end
end
