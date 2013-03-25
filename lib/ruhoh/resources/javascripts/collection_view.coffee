_ = require 'underscore'
BaseCollectionView = require '../../base/collection_view'

class CollectionView extends BaseCollectionView

  constructor: (collection) ->
    super(collection)
    @_cache = {}

  # Load javascripts as defined within the given sub_context
  #
  # Example:
  #   {{# javascripts.load }}
  #     app.js
  #     scroll.js
  #   {{/ javascripts.load }}
  #   (scripts are separated by newlines)
  #
  # This is a convenience method that will automatically create script tags
  # with respect to ruhoh's internal URL generation mechanism; e.g. base_path.
  #
  # @returns[String] HTML script tags for given javascripts.
  load: -> (sub_context) =>
    javascripts = _.reject (s.replace(/\s/g, '') for s in sub_context.split("\n")), (s) -> s is ""
    ("<script src='#{@_make_url(name)}'></script>" for name in javascripts).join("\n")

  # protected

  _make_url: (name) ->
    return name if name.match /^(http:|https:)?\/\//i

    path = if @_cache[name]
      @_cache[name]
    else
      @_cache[name] = "#{name}?#{Math.random()}"

    @ruhoh.to_url(@collection.url_endpoint(), path)

module.exports = CollectionView
