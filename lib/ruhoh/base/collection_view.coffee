class CollectionView

  constructor: (@collection) ->
    @ruhoh = @collection.ruhoh
    @master = null

  new_model_view: (data={}) ->
    return null unless @ruhoh.resources.has_model_view(@resource_name())
    model_view = new (@ruhoh.resources.model_view(@resource_name()))(@ruhoh, data)
    model_view.collection = this
    model_view.master = @master
    model_view

  resource_name: ->
    @collection.resource_name

module.exports = CollectionView
