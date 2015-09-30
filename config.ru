# ./config.ru
require 'rack/iiif'

use Rack::IIIF::Handler
use Rack::IIIF::Router

app = proc do |env|
  [404, {}, ['Nope.']]
end

run app
