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
      # @see http://iiif.io/api/image/2.0/#canonical-uri-syntax
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
    # @todo implement square
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
        REGEX.match(@requested_value) && ![w,h].include?(0)
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
  end
end
