module IIIF
  ##
  # An response object for Image requests
  class ImageResponse < Response
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
      @rotation      = rotation
      @quality       = quality
      @format        = format
    end

    def region=(value)
      @region = Region.new(value)
    end
    ##
    # Base class for IIIF Image Request Parameters
    # @example
    #   param = Parameter.new('full')
    #   param.requested_value # => 'full'
    #
    class Parameter
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

    ##
    # Class representing the region portion of an image request
    #
    # @see http://iiif.io/api/image/2.1/#region
    #
    # @todo implement `square`
    # @todo add better error messages
    class Region < Parameter
      attr_reader :x,:y,:w,:h
      REGEX = /^(?:full)|(?:(?:pct:)?([\d]+,){3}([\d]+))$/

      ##
      # @param [String] requested_value
      # @param [Integer] image_width
      # @param [Integer] image_height
      def initialize(requested_value, image_width = 0, image_height = 0)
        @requested_value = requested_value
        @image_width     = image_width
        @image_height    = image_height

        parse if valid?
      end

      def canonical_value
        @canonical_value ||= canonical_string
      end
      
      ##
      # @return [Boolean]
      #
      # @todo: checking the regex more thoroughly
      def valid?
        REGEX =~ @requested_value && ![w,h].include?(0)
      end

      ##
      # @return [Boolean]
      def full?
        @full ||= begin
           @requested_value == 'full' || 
            (!(w.nil? || h.nil?) && (w == @image_width && h == @image_height))
        end
      end

      ##
      # @return [Boolean]
      def pct?
        @requested_value.start_with?('pct:') && !full?
      end

      private

      def parse
        @x, @y, @w, @h = calculate_canonical unless full?
        true
      end

      def canonical_string
        return 'full' if full?
        parse if @x.nil?
        "#{@x},#{@y},#{@w},#{@h}"
      end

      def calculate_canonical
        x, y, w, h = @requested_value.split(':').last.split(',').map(&:to_i)

        if pct?
          x = x * @image_width / 100
          y = y * @image_height / 100
          w = w * @image_width / 100
          h = h * @image_height / 100
        end

        w = @image_width - x  if x + w > @image_width
        h = @image_height - y if y + h > @image_width

        w = 0 if w < 0
        h = 0 if h < 0

        @full = nil

        [x, y, w, h]
      end
    end

    ##
    #
    class Size < Parameter
    end

    ##
    # Represents the rotation parameter of an image request
    #
    # Values may be floating points from '0' to '360', with an optional '!' 
    # indicating mirroring.
    #
    # @see http://iiif.io/api/image/2.1/#rotation
    class Rotation < Parameter
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
end
