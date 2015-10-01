module IIIF
  ##
  # Resolvers are responsible for converting an ID to a locally available 
  # `IIIF::Image`. They may implement web fetch and caching behavior, depending
  # on the source of the image; or they may simply access existing files on 
  # a local disk, etc...
  #
  # @see IIIF::Image
  #
  # @example
  #   resolver = MyResolver.new(option: value, ...)
  #   image = resolver.resolve('123')
  #
  class Resolver
    ##
    # @param [Hash] opts
    def initialize(opts = {})
      @opts = opts
    end
    
    ##
    # @abstract resolves an ID to an image
    #
    # @return [IIIF::Image] the image with the appropriate id
    def resolve(id)
      raise NotImplementedError, 'A resolver must implement `#resolve`'
    end
  end
end
