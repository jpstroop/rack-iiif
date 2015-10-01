module IIIF
  ##
  # Base class for IIIF Image Request Parameters
  # @example
  #   param = Parameter.new('full')
  #   param.requested_value # => 'full'
  #
  class ImageResponse::Parameter
    attr_reader :requested_value

    ##
    # @param [String] requested_value
    def initialize(requested_value)
      @requested_value = requested_value
    end

    ##
    # @abstract implement to return the canonical value
    # @return [String] the canonical value fore the request
    #
    # @see http://iiif.io/api/image/2.1/#canonical-uri-syntax
    def canonical_value
      raise NotImplementedError
    end

    ##
    # @abstract implement to return a valid response type
    # @return [Boolean] true if the syntax of the requested_value is understood
    def valid?
      raise NotImplementedError
    end

    ##
    # @raise [IIIF::BadRequest] if the value is invalid
    def validate!
      raise IIIF::BadRequest unless valid?
    end
  end
end
