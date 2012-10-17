define [
  "jquery"
  "underscore"
  "backbone"
  "cs!models/layout"
  "cs!models/config"
  "cs!utils/parse"
  "cs!utils/log"
  "yaml"
], ($, _, Backbone, Layout, Config, Parse, Log) ->
  
  # Page Model
  # Represents a post or page.
  Backbone.Model.extend
    initialize: (attrs) ->
      @bind "change:path", (->
        @set "id", @get("path").replace(/^posts\//, "")
      ), this
    
    # Public: Fetch a page/post and resolve all template dependencies.
    # Template promises are *piped* up to the parent page promise.
    # TODO: This probably can be implemented a lot better.
    # Returns: jQuery Deferred object. This ensures all despendencies
    #   are resolved before the generate promise is kept.
    generate: ->
      that = this
      @fetch(
        dataType: "html"
        cache: false
      ).pipe(->
        Log.parseError that.url(), "Page/Post requires a valid layout setting. (e.g. layout: post)"  unless that.get("layout")
        that.sub.set "id", that.get("layout")
        that.sub.generate().pipe ->
          if that.sub.get("layout")
            that.master.set "id", that.sub.get("layout")
            that.master.generate()
      ).fail (jqxhr) ->
        Log.loadError this, jqxhr

    url: ->
      @config.getDataPath @get("path")
    
    # Parse the raw page/post file.
    parse: (data) ->
      @set Parse.frontMatter(data, @url()), silent: true
      @set "content", Parse.content(data, @id), silent: true
      @attributes
