module IIIF
  ##
  # Server-wide `IIIF::Transcoder` registry.
  #
  # A `Singleton` encapsulating transcoders and format support.
  #
  # @example registering a transcoder
  #   TranscoderRegistry.instance.add(my_transcoder)
  #   TranscoderRegistry.instance.all
  # 
  # @example finding supported target formats
  #   TranscoderRegistry.instance.add(jp2_to_png_transcoder)
  #   TranscoderRegistry.instance.formats_for(:jpg) 
  #   # => [:png]
  #   
  class TranscoderRegistry
    include Singleton

    def initialize
      @transcoders = []
    end

    ##
    # @param [IIIF::Transcoder] transcoder
    def add(transcoder)
      @transcoders << transcoder
    end
    
    ##
    # @param [Array<IIIF::Transcoder>] an array of the registered transcoders
    def all
      @transcoders
    end

    ##
    # @param [Symbol] source_format  the format to transcode from
    # @return [Array<Symbol>] an array of target formats supported for the 
    #   source_format
    def formats_for(source_format)
      []
    end
  end
end
