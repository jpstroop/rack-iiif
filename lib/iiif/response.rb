module IIIF
  class Response
    ##
    # @abstract implement to return a valid response type
    # @return [Symbol] one of :info, :image
    def type
      raise NotImplementedError
    end
  end
end
