module IIIF
  ##
  # An response object for Image requests
  class ImageResponse < Response
    # @!attribute [rw] id
    #   @return [String] the id for the resource
    # @!attribute [rw] region
    #   @return [String] the region segement of the request
    # @!attribute [rw] size
    #   @return [String] the size segement of the request
    # @!attribute [rw] rotation
    #   @return [String] the rotation segement of the request
    # @!attribute [rw] quality
    #   @return [String] the quality segement of the request
    # @!attribute [rw] format
    #   @return [String] the format segement of the request
    attr_accessor :id, :region, :size, :rotation, :quality, :format

    ##
    # @param [String] id
    # @param [String] region
    # @param [String] size
    # @param [String] rotation
    # @param [String] quality
    # @param [String] format
    def initialize(id:, region:, size:, rotation:, quality:, format:)
      self.id       = id
      self.region   = region
      self.size     = size
      self.rotation = rotation
      self.quality  = quality
      self.format   = format
    end
  end
end
