BaseCollection = require '../../base/collection'
utils = require '../../utils'

class Collection extends BaseCollection
  resource_name: 'data'
  
  generate: ->
    utils.parse_yaml_file(@ruhoh.paths.base, "#{@resource_name}.yml") || {}

module.exports = Collection
