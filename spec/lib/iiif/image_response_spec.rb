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

end
