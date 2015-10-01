module IIIF
  ##
  # An response object for Image requests
  class ImageResponse < Response
    require 'iiif/image_response/parameter'

    autoload :Region,     'iiif/image_response/region'
    autoload :Size,       'iiif/image_response/size'
    autoload :Rotation,   'iiif/image_response/rotation'

    # @!attribute [rw] id
    #   @return [String] the id for the resource
    # @!attribute [r] region
    #   @return [String] the region segement of the request
    # @!attribute [r] size
    #   @return [String] the size segement of the request
    # @!attribute [r] rotation
    #   @return [String] the rotation segement of the request
    # @!attribute [r] quality
    #   @return [String] the quality segement of the request
    # @!attribute [r] format
    #   @return [String] the format segement of the request
    attr_reader :region, :size, :rotation, :quality, :format
    attr_accessor :id

    ##
    # @param [String] id
    # @param [String] region
    # @param [String] size
    # @param [String] rotation
    # @param [String] quality
    # @param [String] format
    def initialize(id:, region:, size:, rotation:, quality:, format:)
      @id            = id
      self.region    = region
      @size          = size
      self.rotation  = rotation
      @quality       = quality
      @format        = format
    end

    def region=(value)
      @region = Region.new(value)
    end

    def rotation=(value)
      @rotation = Rotation.new(value)
    end
  end
end
