module IIIF
  ##
  # Represents the rotation parameter of an image request
  #
  # Values may be floating points from '0' to '360', with an optional '!' 
  # indicating mirroring.
  #
  # @see http://iiif.io/api/image/2.1/#rotation
  class ImageResponse::Rotation < ImageResponse::Parameter
    REGEX = /^(?<mirror>!)?(?<rotation>\d{1,3}(?:\.\d+)?)$/

    ##
    # @return [Boolean] `true` if the value is a valid rotation
    def valid?
      REGEX =~ @requested_value && in_range?
    end

    ##
    # @see Parameter#canonical_value
    def canonical_value
      "#{mirror? ? '!' : nil}#{rotation_string}"
    end

    ##
    # @return [Boolean] true if the rotation is between 0 and 360
    def in_range?
      !rotation.nil? && rotation <= 360 
    end

    ##
    # @return [Float, nil] the rotation value as a float. `nil` if none is 
    #   found
    def rotation
      parse.nil? ? nil : parse[:rotation].to_f
    end

    ##
    # @return [Boolean] true if the '!' mirror character is present in the
    #   request value
    def mirror?
      parse.nil? ? false : !parse[:mirror].nil?
    end

    private

    ##
    # @return [MatchData, nil] a regex match with `:mirror` and `:rotation`
    #   values. `nil` if no match.
    def parse
      @match ||= REGEX.match(@requested_value)
    end

    ##
    # @return [String] rotation value as integer if x.0, as float if there 
    #   is a value right ofthe decimal
    def rotation_string
      int_rotation = rotation.to_i

      rotation == int_rotation ? int_rotation.to_s : rotation.to_s
    end
  end
end
