require 'singleton'

##
# IIIF behavior for use with Rack::IIIF middleware.
#
# @example configuration
#   IIIF.configure do |config|
#     config.add_resolver :my_resolver, my_resolver_instance
#     config.add_transcoder my_transcoder
#   end
#
module IIIF
  autoload :Image,              'iiif/image'
  autoload :Resolver,           'iiif/resolver'
  autoload :ImageInfoExtractor, 'iiif/image_info_extractor'
  autoload :TranscoderRegistry, 'iiif/transcoder_registry'

  # responses
  autoload :Response,           'iiif/response'
  autoload :InfoResponse,       'iiif/info_response'
  autoload :ImageResponse,      'iiif/image_response'
  autoload :RedirectResponse,   'iiif/redirect_response'

  ##
  # Server-wide configuration
  class Configuration
    include Singleton
    
    # @!attribute [r] resolvers
    #   @return [Hash<Symbol, IIIF::Resolver>]
    attr_reader :resolvers

    def initialize
      @resolvers = {}
    end

    ##
    # Resets all configuration variables
    def reset!
      @resolvers.clear
    end

    ##
    # @param [Symbol] name  a symbol representing the resolver key
    # @param [IIIF::Resolver] resolver  a resolver instance
    def add_resolver(name, resolver)
      @resolvers[name] = resolver
    end

    ##
    # @param [IIIF::Transcoder] resolver  a resolver instance
    def add_transcoder(transcoder)
      transcoders.add(transcoder)
    end

    ##
    # @return [TranscoderRegistry] the registered transcoders
    def transcoders
      TranscoderRegistry.instance
    end
  end

  def self.configure(&block)
    yield Configuration.instance if block_given?
  end

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
