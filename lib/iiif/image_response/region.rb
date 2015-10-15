module IIIF
  ##
  # Class representing the region portion of an image request
  #
  # @see http://iiif.io/api/image/2.1/#region
  #
  # @todo implement `square`
  # @todo add better error messages
  class ImageResponse::Region < ImageResponse::Parameter
    attr_reader :x,:y,:w,:h
    REGEX = /^(?:full)|(?:square)|(?:(?:pct:)?([\d]+,){3}([\d]+))$/

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
      return false if square?
      REGEX =~ @requested_value && ![w,h].include?(0)
    end

    ##
    # @see Parameter#validate!
    def validate!
      raise(IIIF::NotImplemented, '`square` regions are not supported!') if
        square?
      super
    end

    ##
    # @return [Boolean]
    def full?
      @full ||= begin
                  @requested_value == 'full' ||
                    @requested_value == 'square' && @image_width == @image_height ||
                    (!(w.nil? || h.nil?) && (w == @image_width && h == @image_height))                  
                end
    end

    ##
    # @return [Boolean]
    def pct?
      @requested_value.start_with?('pct:') && !full?
    end

    ##
    # @return [Boolean]
    def square?
      @requested_value == 'square'
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
      return calculate_square if square?
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

    ##
    # Gives x,y,w,h format for a square version of this image
    def calculate_square
      short = [@image_width, @image_height].min 
      [(@image_width - short) / 2, (@image_height - short) / 2, short, short]
    end
  end
end
