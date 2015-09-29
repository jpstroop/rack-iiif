# ./config.ru
require 'rack/iiif'

app = proc do |env|
  [200, {}, ['hello world']]
end

run app
