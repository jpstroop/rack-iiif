require 'rack'

module Rack
  ##
  # Rack middleware for handling IIIF Image API responses
  # 
  # @see http://www.rubydoc.info/github/rack/rack/master/file/SPEC for the Rack specification
  # @see http://iiif.io/api/image/2.1/ for the IIIF Image API 2.1 (draft)
  class IIIF
    ##
    # @param [#call] app
    def initialize(app)
      @app = app
    end
    
    ##
    # @param [Hash] env
    def call(env)
      status, headers, response = @app.call(env)
      [status, headers, response]
    end
  end
end
