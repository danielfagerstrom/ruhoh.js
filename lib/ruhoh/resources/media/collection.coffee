BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'media'
  
  url_endpoint: ->
    "/assets/media"
    
module.exports = Collection
