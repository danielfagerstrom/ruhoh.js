define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/parse"
  "cs!utils/log"
  "yaml"
], ($, _, Backbone, Parse, Log) ->
  
  # Pages Dictionary is a hash representation of all pages in the app.
  # This is used as the primary pages database for the application.
  # A page is referenced by its unique id attribute .
  # When working with pages you only need to reference its id.
  # Valid id nodes are expanded to the full page object via the dictionary.
  Backbone.Model.extend
    initialize: (attrs) ->

    generate: ->
      @fetch
        dataType: "html"
        cache: false

    url: ->
      @config.getDataPath "/database/pages_dictionary.yml"

    parse: (response) ->
      data = jsyaml.load(response)
      # Need to append the page id to urls for client-side rendering.
      # i.e. We need to tell javascript where the file is.
      for id of data
        data[id]["url"] += ("?path=" + @config.fileJoin(@config.get("pagesDirectory"), id))
      @set data
      @attributes
