require 'spec_helper.rb'

describe IIIF::ImageInfoExtractor::Jp2Extractor do
  let(:color_jp2) { fixture_path('color.jp2') }
  let(:gray_jp2) { fixture_path('gray.jp2') }
  let(:jp2_with_precincts) { fixture_path('precincts.jp2') }
  let(:boilerplate_info) do
    {
      'profile' => [
        'the compliance uri MUST be first',
        { 'qualities' => [ 'default', 'bitonal' ] }
      ]
    }
  end

  shared_examples_for 'a jp2' do |expected|
    describe 'teh metadatas' do
      it 'height' do
        expect(subject['height']).to eq expected[:height]
      end
      it 'width' do
        expect(subject['width' ]).to eq expected[:width]
      end
      it 'correct qualities' do
        qualities = subject['profile'][1]['qualities'].sort
        expect(qualities).to eq expected[:qualities].sort
      end
      it 'tile info' do
        expect(subject['tiles']).to eq expected[:tiles]
      end
      it 'sizes' do
        expect(subject['sizes']).to eq expected[:sizes]
      end
    end
  end


  describe '#extract' do

    context 'a color jp2' do
      subject { described_class.extract(boilerplate_info, color_jp2) }
      expected = {
        width: 5906,
        height: 7200,
        qualities: ['default', 'color', 'gray', 'bitonal'],
        tiles: [
          { 'width' => 256, 'scaleFactors' => [1, 2, 4, 8, 16, 32, 64] }
        ],
        sizes: [
          { 'width' => 93, 'height' => 113 },
          { 'width' => 185, 'height' => 225 },
          { 'width' => 370, 'height' => 450 },
          { 'width' => 739, 'height' => 900 },
          { 'width' => 1477, 'height' => 1800 },
          { 'width' => 2953, 'height' => 3600 },
          { 'width' => 5906, 'height' => 7200 }
        ]
      }
      it_behaves_like 'a jp2', expected
    end

    context 'a gray jp2' do
      subject { described_class.extract(boilerplate_info, gray_jp2) }
      expected = {
        width: 2477,
        height: 3200,
        qualities: ['default', 'gray', 'bitonal'],
        tiles: [
          { 'width' => 256, 'scaleFactors' => [1, 2, 4, 8, 16, 32, 64] }
        ],
        sizes: [
          { 'width' => 39, 'height' => 50 },
          { 'width' => 78, 'height' => 100 },
          { 'width' => 155, 'height' => 200 },
          { 'width' => 310, 'height' => 400 },
          { 'width' => 620, 'height' => 800 },
          { 'width' => 1239, 'height' => 1600 },
          { 'width' => 2477, 'height' => 3200 }
        ]
      }
      it_behaves_like 'a jp2', expected
    end

    context 'a precinct jp2' do
      # This Jp2 was made with this command:
      # kdu_compress -i spec/fixtures/color.tif
      #   -o spec/fixtures/precincts.jp2
      #   Clevels=6
      #   Cprecincts="{512,512},{256,256},{128,128}"
      subject { described_class.extract(boilerplate_info, jp2_with_precincts) }
      expected = {
        width: 839,
        height: 1080,
        qualities: ['default', 'color', 'gray', 'bitonal'],
        tiles: [
          { 'width' => 512, 'scaleFactors' => [1] },
          { 'width' => 256, 'scaleFactors' => [2] },
          { 'width' => 128, 'scaleFactors' => [4, 8, 16, 32, 64 ] }
        ],
        sizes: [
          { 'width' => 14, 'height' => 17 },
          { 'width' => 27, 'height' => 34 },
          { 'width' => 53, 'height' => 68 },
          { 'width' => 105, 'height' => 135 },
          { 'width' => 210, 'height' => 270 },
          { 'width' => 420, 'height' => 540 },
          { 'width' => 839, 'height' => 1080 }
        ]
      }
      it_behaves_like 'a jp2', expected
    end
  end


end
