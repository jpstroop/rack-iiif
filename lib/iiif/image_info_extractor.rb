module IIIF
  ##
  # Extracts a IIIF info.json-like hash for an image
  #
  # @example 
  #   ImageInfoExtractor.extract(my_image) # => {:image => info}
  #
  class ImageInfoExtractor
    ##
    # @param [Image] image  an image to gather info for
    # @return [Hash] the image info
    def self.extract(image)
      {}
    end
  end
end

