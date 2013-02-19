define [], () ->

  Ruhoh = @Ruhoh

  generate: ->
    routes = {}
    for id, page of Ruhoh.DB.pages
      routes[page.url] = id
    for id, post of Ruhoh.DB.posts.dictionary
      routes[post.url] = id
    routes
    