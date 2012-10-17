define [
  "jquery",
  "underscore",
  "backbone"
], ($, _, Backbone) ->
  
  Backbone.Router.extend
    routes:
      "": "home"
      "index.html": "home"
      "*page": "page"

    # Route.navigate() events trigger these route bindings which
    # set the page id based on the URL.
    # The page change:id event fires,
    # triggering preview.generate(): see preview model for bindings.
    initialize: ->
      that = this
      @bind "route:home", (->
        @preview.page.clear silent: true
        @preview.page.set "path", "pages/index.md"
      ), this
      @bind "route:page", ((page) ->
        @preview.page.clear silent: true
        @preview.page.set "path", (page.split("?path=")[1] or page)
      ), this
      
      # Hand off all link events to the Router.
      $("body").find("a").live "click", (e) ->
        if _.isString($(this).attr("href"))
          that.navigate "/" + $(this).attr("href"),
            trigger: true
        e.preventDefault()
        false

    # Public: Start Router.
    # Returns: Nothing
    start: ->
      Backbone.history.start
        pushState: true
        root: (@preview.config.get("basePath") or "/")
