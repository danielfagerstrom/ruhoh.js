define [
  "jquery"
  "underscore"
  "backbone"
  "cs!router"
  "cs!utils/parse"
  "cs!utils/log"
  "yaml"

  "cs!dictionaries/pages"
  "cs!dictionaries/posts"
  
  "cs!models/config"
  "cs!models/layout"
  "cs!models/page"
  "cs!models/payload"
  "cs!models/preview"
  "cs!models/partial"
  
  "cs!collections/partials"
  
  "handlebars"
  "cs!helpers"
  "markdown"
], ($, _, Backbone, Router, Parse, Log, yaml,
  PagesDictionary, PostsDictionary,
  Config, Layout, Page, Payload, Preview, Partial,
  Partials,
  Handlebars, helpers, Markdown) ->
    
  App =
    router: new Router
    
    # Public: Start the application relative to the site_source.
    # The web-server is responsible for passing site_source in the Header.
    # Once the site_source folder is known we can load config.yml and start the app.
    #
    # Returns: Nothing
    start: ->
      that = this
      
      #that.config = new Config({'site_source' : '/' + jqxhr.getResponseHeader('x-ruhoh-site-source-folder') });
      $.get("/").pipe((a, b, jqxhr) ->
        that.config = new Config(site_source: "/_src/")
        that.config.generate()
      ).done(->
        that.preview = that.router.preview = new Preview(null, that.config)
        that.router.start()
      ).fail (jqxhr) ->
        Log.loadError this, jqxhr

  App
