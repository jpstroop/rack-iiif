module IIIF
  ##
  # Base class for IIIF responses
  class Response
    # @!attribute [rw] status
    #   @return [Integer] the HTTP status code to use in the response
    attr_accessor :status

    # @!attribute [w] headers
    #   @return [Hash] a hash of HTTP headers
    # @!attribute [w] body
    #   @return [#each] a rack response body
    attr_writer :body, :headers

    ##
    # @abstract implement to return a valid response type
    # @return [Symbol] one of :info, :image, :redirect
    def type
      raise NotImplementedError
    end

    ##
    # @return [Array<Integer, Hash, #each>] a rack response
    # @see http://www.rubydoc.info/github/rack/rack/master/file/SPEC
    def to_response(old_headers = {})
      [status, old_headers.merge(headers), [body]]
    end

    ##
    # @return [#each] a rack response body
    def body
      @body ||= ''
    end

    ##
    # @return [Hash<#to_s, #to_s>] a hash of HTTP headers
    def headers
      @headers ||= {}
    end
  end
end
