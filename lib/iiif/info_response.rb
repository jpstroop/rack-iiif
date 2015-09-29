module IIIF
  class InfoResponse
    attr_reader :id

    def initialize(id:)
      @id = id
    end
    
    ##
    # @return [Symbol] one of :info, :image
    def type
      :info
    end
  end
end
