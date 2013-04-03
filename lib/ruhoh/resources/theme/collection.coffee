Q = require 'q'
FS = require 'q-io/fs'
BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'theme'
  
  url_endpoint: ->
    "/assets"

  namespace: ->
    @config()['name']

  hasPaths: ->
    FS.isDirectory @ruhoh.paths.theme

  # noop
  generate: ->
    Q.resolve {}
    
module.exports = Collection
