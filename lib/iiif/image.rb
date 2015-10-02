module IIIF
  ##
  # A locally available image
  class Image
    # @!attribute [r] path
    #   @return [String]
    # @!attribute [r] source_format
    #   @return [Symbol]
    # @!attribute [r] base_uri
    #   @return [String]
    attr_reader :path, :source_format, :base_uri

    ##
    # @param [String] path  a file path to the local copy of the image
    # @param [Symbol] source_format  a format symbol
    # @param [String] base_uri  the json-ld @id (URI_ of the image
    # @param [Hash] info  the image info to be used in JSON responses
    # @param [#extract] extractor  an extractor to create an info hash
    #   for this image
    def initialize(path, source_format, base_uri, info: nil,
                   extractor: ImageInfoExtractor)
      @path = path
      @source_format = source_format
      @base_uri = base_uri
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
      IIIF::Configuration.instance.transcoders.formats_for(source_format)
    end

    ##
    # @example
    #   my_image.to_jpg(region, size, rotation, quality)
    #
    def method_missing(name, *args, &block)
      format = method_to_format_symbol(name)
      return transcode(*args, format) if format
      super
    end

    def respond_to_missing?(name, include_private = false)
      !method_to_format_symbol(name).nil? || super
    end

    private

    ##
    # @param [String] name  method name
    # @return [Symbol, nil] gives the format symbol if the name is of form
    #   `to_{format}` and matches a supported format
    def method_to_format_symbol(name)
      return nil unless name[0..2] == 'to_'
      format_sym = name[3..-1].to_sym
      return format_sym if formats.include?(format_sym)
      nil
    end

    ##
    # @return [IO] the file contents
    def transcode(region, size, rotation, quality, format)
      StringIO.new('')
    end
  end
end
