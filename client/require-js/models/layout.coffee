define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/parse"
  "cs!utils/log"
  "yaml"
], ($, _, Backbone, Parse, Log) ->
  
  # Layout Model
  Backbone.Model.extend
    initialize: (attrs) ->

    generate: ->
      @fetch
        dataType: "html"
        cache: false

    url: ->
      @config.getThemePath "/layouts/" + @id + ".html"

    parse: (data) ->
      @set Parse.frontMatter(data, @url())
      @set "content", Parse.content(data)
      @attributes

