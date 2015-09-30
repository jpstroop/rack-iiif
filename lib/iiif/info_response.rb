require 'json' 

module IIIF
  class InfoResponse < Response
    attr_reader :id

    def initialize(id:)
      @id = id
      @status = 200
    end
    
    ##
    # @return [Symbol] one of :info, :image
    def type
      :info
    end

    def body
      {}.to_json
    end
  end
end
