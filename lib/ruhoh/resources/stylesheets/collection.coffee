BaseCollection = require '../../base/collection'

class Collection extends BaseCollection
  resource_name: 'stylesheets'
  
  url_endpoint: ->
    "assets/#{@namespace()}"
    
module.exports = Collection
