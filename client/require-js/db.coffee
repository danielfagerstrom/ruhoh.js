define [
  "jquery"
  "cs!models/site"
], ($, Site) ->

  Ruhoh = @Ruhoh

  update_all: ->
    $.when(
      Site.generate()
    ).pipe((site) =>
      @site = site
    )