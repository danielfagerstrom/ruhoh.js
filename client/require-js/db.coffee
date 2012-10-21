define [
  "jquery"
  "cs!models/site"
  "cs!dictionaries/posts"
  "cs!dictionaries/pages"
], ($, Site, Posts, Pages) ->

  Ruhoh = @Ruhoh

  update_all: ->
    $.when(
      Site.generate()
      (new Posts).generate2()
      (new Pages).generate2()
    ).pipe((site, posts, pages) =>
      @site = site
      @posts = posts
      @pages = pages
    )