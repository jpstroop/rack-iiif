module IIIF
  ##
  # A locally available image
  class Image
    # @!attribute [r] path
    #   @return [String]
    # @!attribute [r] source_format
    #   @return [Symbol]
    attr_reader :path, :source_format

    ##
    # @param [String] path  a file path to the local copy of the image
    # @param [Symbol] source_format  a format symbol
    # @param [Hash] info  the image info to be used in JSON responses
    # @param [#extract] extracter  an extracter to create an info hash 
    #   for this image
    def initialize(path, source_format, info: nil, 
                   extractor: ImageInfoExtractor)
      @path = path
      @source_format = source_format
      @info = info
      @extractor = extractor
    end

    ##
    # @return [Hash] the image info to be used in JSON responses
    def info
      @info ||= @extractor.extract(self)
    end
    
    ##
    # @return [Array<Symbol>] an array of formats supported by this image
    def formats
      []
    end

    ##
    # @example 
    #   my_image.to_jpg(region, size, rotation, quality)
    #
    def method_missing(name, *args, &block)
      if name[0..2] == 'to_'
        format = name[3..-1].to_sym
        return transcode(*args, format) if formats.include?(format)
      end

      super
    end

    private

    ##
    # @return [IO] the file contents
    def transcode(region, size, rotation, quality, format)
      StringIO.new('')
    end
  end
end
