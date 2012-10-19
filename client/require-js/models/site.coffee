define [
  "jquery"
  "yaml"
], ($) ->

  Ruhoh = @Ruhoh

  generate: ->
    $.get(Ruhoh.paths.site_data)
    .pipe((response) ->
      site = jsyaml.load(response)
      site.config = Ruhoh.config
      site
    )
    