_ = require 'underscore'
BaseCollectionView = require '../../base/collection_view'

class CollectionView extends BaseCollectionView

  constructor: (collection) ->
    super(collection)
    @_cache = {}

  # Load Stylesheets as defined within the given sub_context
  #
  # Example:
  #   {{# stylesheets.load }}
  #     global.css
  #     custom.css
  #   {{/ stylesheets.load }}
  #   (stylesheets are separated by newlines)
  #
  # This is a convenience method that will automatically create link tags
  # with respect to ruhoh's internal URL generation mechanism; e.g. base_path
  #
  # @returns[String] HTML link tags for given stylesheets
  load: -> (sub_context) =>
    stylesheets = _.reject (s.replace(/\s/g, '') for s in sub_context.split("\n")), (s) -> s is ""
    (for name in stylesheets
      "<link href='#{@_make_url(name)}' type='text/css' rel='stylesheet' media='all'>"
    ).join("\n")

  # protected

  _make_url: (name) ->
    return name if name.match /^(http:|https:)?\/\//i

    path = if @_cache[name]
      @_cache[name]
    else
      @_cache[name] = "#{name}?#{Math.random()}"

    @ruhoh.to_url(@collection.url_endpoint(), path)

module.exports = CollectionView
