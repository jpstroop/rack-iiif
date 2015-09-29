require 'rack'

module Rack
  ##
  # Rack middleware for handling IIIF Image API responses
  # 
  # @see http://www.rubydoc.info/github/rack/rack/master/file/SPEC for the Rack specification
  # @see http://iiif.io/api/image/2.1/ for the IIIF Image API 2.1 (draft)
  module IIIF
    ##
    # Handles responses from IIIF service classes
    class Handler
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
      # rescue MyErrorType => e
      #   [e.status, e.headers, [e.message]]
      end
    end

    ##
    # Converts a request to IIIF response objects accrding to the request path
    class Router
      ##
      # @param [#call] app
      def initialize(app)
        @app = app
      end
      
      ##
      # @param [Hash] env
      # @return [Array<Integer, Hash, IIIF::Response>] the response
      def call(env)
        @app.call(env)
      end
    end
  end
end
