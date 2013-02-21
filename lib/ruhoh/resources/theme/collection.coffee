Q = require 'q'
BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'theme'
  
  url_endpoint: ->
    "/assets"

  namespace: ->
    @config()['name']

  # noop
  generate: ->
    Q.resolve {}
    
module.exports = Collection
