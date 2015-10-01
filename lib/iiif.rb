##
# IIIF behavior for use with Rack::IIIF middleware
module IIIF
  autoload :Response,         'iiif/response'
  autoload :InfoResponse,     'iiif/info_response'
  autoload :ImageResponse,    'iiif/image_response'
  autoload :RedirectResponse, 'iiif/redirect_response'

  ##
  # A base class for HTTP request errors.
  class RequestError < RuntimeError
    STATUS = 500
    
    def status
      self.class::STATUS
    end

    def headers
      {}
    end
  end

  ##
  # An error for 400 Bad Request responses
  #
  # @see IIIF::RequestError
  class BadRequest < RequestError
    STATUS = 400
  end

  ##
  # An error for 404 Not Found responses
  #
  # @see IIIF::RequestError
  class NotFound < RequestError
    STATUS = 404
  end

  ##
  # An error for 405 Method Not Allowed responses
  #
  # @see IIIF::RequestError
  class MethodNotAllowed < RequestError
    STATUS = 405
  end

  ##
  # An error for 501 Not Implemented responses
  #
  # @see IIIF::RequestError
  class NotImplemented < RequestError
    STATUS = 501
  end
end
