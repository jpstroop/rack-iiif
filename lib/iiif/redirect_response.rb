module IIIF
  ##
  #
  class RedirectResponse < Response
    # @!attribute [r] target
    #   @return [#to_s]  the URI target for redirect
    attr_reader :target

    ##
    # @param [#to_s] target  a URI-like string
    # @status [Integer] status  a valid HTTP status code
    def initialize(target, status = 303)
      @target = target
      self.status = status
    end

    ##
    # @return [Symbol] :redirect
    def type
      :redirect
    end

    ##
    # @see Response#headers
    def headers
      @headers ||= { 'Location' => target }
    end
  end
end
