require 'vips'

module IIIF
  ##
  # Extracts a info for common image formats
  #
  # @example
  #   VipsExtractor.extract(seed, my_image) # => {:image => info}
  #
  class ImageInfoExtractor::VipsExtractor
    include VIPS

    # @return [Array] the source formats this extractor can handle
    def self.formats
      [ 'jpg', 'tif', 'png' ]
    end

    ##
    # @param [Hash] info  a hash containing boilerplate info for the server
    # @param [Image] image  an image to gather info for
    # @return [Hash] the image info
    def self.extract(info, image_path)
      vips_image = VIPS::Image.magick(image_path)
      info['height'], info['width'] = read_height_and_width(vips_image)
      info['profile'][1]['qualities'].push(*read_qualities(vips_image))
      info
    end

    private

    def self.read_height_and_width(vips_image)
      return [vips_image.y_size, vips_image.x_size]
    end

    def self.read_qualities(vips_image)
      vips_image.bands == 3 ? [ 'color', 'gray'] : [ 'gray' ]
    end
  end
end
