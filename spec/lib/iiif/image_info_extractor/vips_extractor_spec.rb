require 'spec_helper.rb'

describe IIIF::ImageInfoExtractor::VipsExtractor do
  let(:color_jpg) { fixture_path('color.jpg') }
  let(:gray_jpg) { fixture_path('gray.jpg') }
  let(:color_png) { fixture_path('color.png') }
  let(:gray_png) { fixture_path('gray.png') }
  let(:color_tif) { fixture_path('color.tif') }
  let(:gray_tif) { fixture_path('gray.tif') }
  let(:boilerplate_info) do
    {
      'profile' => [
        'the compliance uri MUST be first',
        { 'qualities' => [ 'default', 'bitonal' ] }
      ]
    }
  end

  shared_examples_for 'a format vips supports' do |expected|
    describe 'teh metadatas' do
      it 'height' do
        expect(subject['height']).to eq expected[:height]
      end
      it 'width' do
        expect(subject['width']).to eq expected[:width]
      end
      it 'correct qualities' do
        qualities = subject['profile'][1]['qualities'].sort
        expect(qualities).to eq expected[:qualities].sort
      end
    end
  end

  describe '#extract' do

    context 'a color jpg' do
      subject { described_class.extract(boilerplate_info, color_jpg) }
      expected = {
        width: 200,
        height: 279,
        qualities: ['default', 'color', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

    context 'a gray jpg' do
      subject { described_class.extract(boilerplate_info, gray_jpg) }
      expected = {
        width: 200,
        height: 126,
        qualities: ['default', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

    context 'a color png' do
      subject { described_class.extract(boilerplate_info, color_png) }
      expected = {
        width: 200,
        height: 250,
        qualities: ['default', 'color', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

    context 'a gray png' do
      subject { described_class.extract(boilerplate_info, gray_png) }
      expected = {
        width: 200,
        height: 139,
        qualities: ['default', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

    context 'a color tif' do
      subject { described_class.extract(boilerplate_info, color_tif) }
      expected = {
        width: 203,
        height: 141,
        qualities: ['default', 'color', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

    context 'a gray tif' do
      subject { described_class.extract(boilerplate_info, gray_tif) }
      expected = {
        width: 207,
        height: 297,
        qualities: ['default', 'gray', 'bitonal']
      }
      it_behaves_like 'a format vips supports', expected
    end

  end


end
