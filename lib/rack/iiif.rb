require 'rack'

module Rack
  class IIIF
    def initialize(app)
      @app = app
    end
    
    def call(env)
      status, headers, response = @app.call(env)
      [status, headers, response]
    end
  end
end
