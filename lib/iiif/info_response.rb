require 'json' 

module IIIF
  class InfoResponse < Response
    # @!attribute [r] id
    #   @return [String] the id
    attr_reader :id

    ##
    # @param [String] id
    def initialize(id:)
      @id = id
      @status = 200
    end
    
    ##
    # @return [Symbol] one of :info, :image
    def type
      :info
    end

    ##
    # @return [Array<String>]  a Rack-friendly JSON body
    def body
      [{}.to_json]
    end
  end
end
