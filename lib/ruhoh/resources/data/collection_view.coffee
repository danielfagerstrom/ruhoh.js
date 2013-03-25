_ = require 'underscore'

class CollectionView
  # attr_accessor :collection, :master

  constructor: (collection) ->
    @ruhoh = collection.ruhoh
    @setup_promise = @ruhoh.db[collection.resource_name]().then (data) =>
      _.extend this, data

module.exports = CollectionView

