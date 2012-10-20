define [
  "jquery"
  "cs!models/site"
  "cs!dictionaries/posts"
], ($, Site, Posts) ->

  Ruhoh = @Ruhoh

  update_all: ->
    $.when(
      Site.generate()
      (new Posts).generate2()
    ).pipe((site, posts) =>
      @site = site
      @posts = posts
    )