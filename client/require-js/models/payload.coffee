define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
], ($, _, Backbone, Log) ->
  
  # Payload Model
  # payload is the data structure available to the templates via Mustache.
  Backbone.Model.extend initialize: ->
    @set buildUrl: ->
      (name, render) ->
        render "GUPPY"
