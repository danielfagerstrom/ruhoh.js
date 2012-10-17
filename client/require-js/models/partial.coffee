define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
  "handlebars"
], ($, _, Backbone, Log, Handlebars) ->
  
  # Partial Model
  Backbone.Model.extend
    generate: ->
      @fetch dataType: "html", cache: false

    url: ->
      @config.getDataPath "/partials/" + @get("path")

    parse: (data) ->
      @set "content", data
      @attributes
