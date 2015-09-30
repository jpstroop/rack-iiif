require 'rack'
require 'iiif'

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

        return response.to_response(headers) if 
          response.respond_to? :to_response
        [status, headers, response]
      rescue ::IIIF::RequestError => e
        [e.status, e.headers, [e.message]]
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
      #
      # @todo handle paths other than base '/'; see prefix at 
      #   http://iiif.io/api/image/2.1/#uri-syntax
      def call(env)        
        status, headers, response = @app.call(env)
        response = build_response(Rack::Request.new(env))
        [status, headers, response]
      end
      
      private 
      
      def build_response(request)
        id, rest = tokenize(request.path)
        return ::IIIF::InfoResponse.new(id: id) if rest == 'info.json'
        return ::IIIF::RedirectResponse.new("#{request.url}/info.json") if 
          rest == nil
      end

      def tokenize(path)
        tokens = path.split('/')
        tokens.shift if tokens.first == ''
        tokens
      end
    end
  end
end
