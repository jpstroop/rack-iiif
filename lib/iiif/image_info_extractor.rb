module IIIF
  ##
  # Extracts a IIIF info.json-like hash for an image
  #
  # @example
  #   ImageInfoExtractor.extract(my_image) # => {:image => info}
  #
  class ImageInfoExtractor

    autoload :Jp2Extractor, 'iiif/image_info_extractor/jp2_extractor'
    autoload :VipsExtractor, 'iiif/image_info_extractor/vips_extractor'

    CONTEXT_URI = "http://iiif.io/api/image/2/context.json"
    COMPLIANCE_URI = "http://iiif.io/api/image/2/level2.json"
    PROTOCOL_URI = "http://iiif.io/api/image"

    ##
    # @param [Image] image  an image to gather info for
    # @return [Hash] the image info
    def self.extract(image)
      info_seed = {
        '@context' => CONTEXT_URI,
        '@id' => image.id,
        'protocol' => PROTOCOL_URI,
        'profile' => [
          COMPLIANCE_URI,
          {
            'qualities' => [ 'default', 'bitonal' ]
            # TODO: we need 'formats' from the transcoder
            # TODO: we need 'supports' from ... somewhere. Could possibly
            # hard-code, though some of the > 2 features should probably
            # optional
          }
        ]
      }
      if Jp2Extractor.formats.include?(image.source_format)
        return Jp2Extractor.extract(info_seed, image.path)
      elsif VipsExtractor.formats.include?(image.source_format)
        return VipsExtractor.extract(info_seed, image.path)
      else
        msg = "this server does not support #{fmt} as a source format"
        raise NotImplementedError msg
      end
    end

  end

end
