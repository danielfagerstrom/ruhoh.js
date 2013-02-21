BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'dash'
  
  url_endpoint: ->
    "/dash"
    
module.exports = Collection
