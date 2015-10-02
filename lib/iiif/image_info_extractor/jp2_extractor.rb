module IIIF
  ##
  # Extracts a JPEG 2000-specific info for an image
  #
  # "Pg. N" annotations throughout refer to ISO/IEC 15444-1:2004 (E).
  # ISO/IEC 15444-2:2004 (Jp2 Extensions) is referenced once when dealing with
  # color profiles.
  #
  # @example
  #   Jp2InfoExtractor.extract(seed, my_image) # => {:image => info}
  #
  class ImageInfoExtractor::Jp2Extractor
    ##
    # @param [Hash] info  a hash containing boilerplate info for the server
    # @param [Image] image  an image to gather info for
    # @return [Hash] the image info

    def self.extract(info, image_path)
      File.open(image_path, 'rb') do |jp2|
        read_to_box('ihdr', jp2)
        img_height, img_width = read_height_and_width(jp2)
        info['height'], info['width'] = [ img_height, img_width ]

        read_to_box('colr', jp2)
        info['profile'][1]['qualities'].push(*read_qualities(jp2))

        read_to_marker('ff4f', jp2) # SOC (start of codestream), pg. 19

        # tile size
        read_to_marker('ff51', jp2) # SIZ (image and tile siz), pg. 21
        tile_width, tile_height = read_tile_width_and_height(jp2)

        # decomposition levels
        read_to_marker('ff52', jp2) # COD (coding style default), pg. 22
        level_count = levels_from_cod(jp2)

        # tile info if we have jp2 "tiles" (as opposed to precincts)
        if tile_height != info['height'] && tile_width != info['width']
          info['tiles'] = []
          info['tiles'] << { 'width' => tile_width }
          info['tiles'][0]['height'] = tile_height if tile_width != tile_height
          info['tiles'][0]['scaleFactors'] = (0..level_count).map { |l| 2**l }
        end

        # tile info if we have precincts
        jp2.read(4) # through code block stuff (See table A.15, pg. 24)

        # We may have precincts if Scod or Scoc = xxxx xxx0. However, we don't
        # to examine as this is the last section in the COD segment. Instead
        # check if the next byte == 0xFF. If it is, then we don't have a Precint
        # size parameter and we've moved on to either the COC (optional,
        # marker = 0xFF53) or the QCD (required, marker = 0xFF5C).
        b = jp2.read(1)
        unless b.unpack('H*')[0] == 'ff' && info['tiles'].nil?
          dimensions = []
          (level_count+1).times do |i|
            dimensions << read_precint_height_and_width(b)
            b = jp2.read(1)
          end
          # The last value applies to the highest resolution,
          # i.e. level 0, i.e. scaleFactor 1, so:
          dimensions.reverse!
          # group the levels by dimenson, i.e.
          # {[512, 512]=>[0], [256, 256]=>[1], [128, 128]=>[2, 3, 4, 5, 6]}
          groups = {}
          dimensions.each_with_index do |d,i|
            groups[d] ||= []
            groups[d] << i
          end
          # finally
          info['tiles'] = []
          groups.each do |height_width, levels|
            height, width = height_width
            entry = { 'width' => width }
            entry['height'] = height if width != height
            entry['scaleFactors'] = levels.map { |l| 2**l }
            info['tiles'] << entry
          end
        end

        # sizes (calculated from number of levels, w, and h)
        info['sizes'] = sizes_for_levels(img_width, img_height, level_count)

      end # /File.open
      info
    end


    private

    def self.read_to_box(name, jp2)
      window = Array.new(4)
      while window.join != name do
        window.shift
        window << jp2.readbyte.chr
      end
    end

    def self.read_to_marker(value, jp2)
      window = Array.new(2)
      while window.join != value do
        window.shift
        window << jp2.read(1).unpack('H*')[0]
      end
    end

    # jp2 cursor is at the start of the ihdr box
    def self.read_height_and_width(jp2)
      h = jp2.read(4).unpack('N')[0].to_i # height (pg. 136)
      w = jp2.read(4).unpack('N')[0].to_i # width
      [h, w]
    end

    # jp2 cursor is at the start of the colr box
    def self.read_qualities(jp2)
      colr_meth = jp2.read(1).unpack('b')[0] # METH (pg. 138)
      colr_prec = jp2.read(1).unpack('b')[0] # PREC (pg. 139)
      colr_approx = jp2.read(1).unpack('b')[0] # APPROX (pg. 139)
      if colr_meth == '1' # Enumerated Colourspace
        enum_cs = jp2.read(4).unpack('N')[0] # EnumCS (pg. 139)
        return ['color', 'gray' ] if [16, 18].include?(enum_cs)
        return ['gray'] if enum_cs == 17
        # Should we raise something 5xxish about the color space being uknown
        # per JP2 spec pg. 139?
      elsif ['2','3','4'].include?(colr_meth)
        # We assume that if you're working w. colors profile that you have
        # colors (and not just grayscale). Loris also extracts the color profile
        # for these to the info cache and maps it to sRGB for derivatives,
        # using LCMS bindings. Ruby LCMS bindings don't seem well supported, so
        # skipping for now.
        # '2' = Restricted ICC color profile
        # '3' = Any ICC method
        # '4' = Vendor Colour method
        # See also:
        #  * jp2 extension spec (ISO 15444-2): pg. 182,
        #      Table M.24 (Color spec box legal values)
        #  * Loris: https://github.com/loris-imageserver/loris/blob/d5c6dda4a099f0e1dd89bf45ce9725dca87ede98/loris/img_info.py#L270-L279
        return [ 'color', 'gray' ]
      end

    end

    # jp2 cursor is at the byte after the SIZ (0xff51) marker. See pg. 22
    def self.read_tile_width_and_height(jp2)
      jp2.read(20) # Through Lsiz (16 bits), Rsiz (16), Xsiz (32), Ysiz (32),
                   # XOsiz (32), and YOsiz (32)
      w = jp2.read(4).unpack('N')[0].to_i
      h = jp2.read(4).unpack('N')[0].to_i
      [w, h]
    end

    # jp2 cursor is at the byte after the COD (0xff52) marker
    def self.levels_from_cod(jp2)
      jp2.read(7) # Through Lcod (16 bits), Scod (8), SGcod (32)
      # We only need the first byte of SPCod - See table A.15, pg. 24
      jp2.read(1).unpack('C')[0]
    end

    def self.sizes_for_levels(width, height, level_count)
      sizes = [ ]
      (level_count+1).times do
        sizes << { 'width' => width, 'height' => height }
        # Kakadu uses the ceiling when the number of levels to discard
        # is passed as -reduce, i.e. Given an image that is 7200 x 5906:
        # kdu_expand -i my_img.jp2 -o out.bmp -reduce 3
        # makes an image that is 900 x __739__, even though
        # (((5906 / 2) / 2) / 2) = 738
        # and
        # (((5906 / 2.0) / 2.0) / 2.0) = 738.25
        # This may be different in openjpeg and the rounding method will need
        # to be parameterized if so.
        width = (width / 2.0).ceil
        height = (height / 2.0).ceil
      end
      sizes.reverse # spec says smallest first
    end

    def self.read_precint_height_and_width(b)
      # See table A.21, pg. 26. H is the first nibble, W is the second
      h,w = b.unpack('H*').shift.split(//).map(&:to_i).map { |n| 2**n }
    end

  end
end
