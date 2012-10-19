define [
  "jquery"
  "cs!router"
  "cs!utils/log"
  "cs!ruhoh"
  "cs!db"
  "cs!models/preview"
], ($, Router, Log, Ruhoh, DB, Preview) ->

  opts =
    env: 'development'
    enable_plugins: false
    
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
        that.ruhoh = Ruhoh
        Ruhoh.setup(source: "/_src/")
      ).pipe(->
        Ruhoh.config.env = opts.env
        Ruhoh.setup_paths()
        Ruhoh.setup_urls()
        Ruhoh.setup_plugins() if opts.enable_plugins
        Ruhoh.DB = DB
        DB.update_all()
      ).done(->
        that.config = Ruhoh.config
        that.preview = that.router.preview = new Preview(null, Ruhoh.config)
        that.router.start()
      ).fail (jqxhr) ->
        Log.loadError this, jqxhr

  App
