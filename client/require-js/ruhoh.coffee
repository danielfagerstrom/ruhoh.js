define [
  "jquery"
  "cs!utils/log"
  "cs!models/config"
  "cs!paths"
  "cs!urls"
], ($, Log, Config, Paths, Urls) ->

  $.extend @Ruhoh, {
    log: Log
    Root: '/client'
    names:
      assets: 'assets',
      config_data: 'config.yml',
      compiled: 'compiled',
      dashboard_file: 'dash.html',
      layouts: 'layouts',
      media: 'media',
      pages: 'pages',
      partials: 'partials',
      plugins: 'plugins',
      posts: 'posts',
      javascripts: 'javascripts',
      scaffolds: 'scaffolds',
      site_data: 'site.yml',
      stylesheets: 'stylesheets',
      system: 'system',
      themes: 'themes',
      theme_config: 'theme.yml',
      widgets: 'widgets',
      widget_config: 'config.yml'

    # Public: Setup Ruhoh utilities relative to the current application directory.
    setup: (opts={}) ->
      @reset()
      @log.log_file = opts.log_file if opts.log_file
      @base = opts.source if opts.source
      @config = new Config
      @config.generate()
    
    reset: ->
      #@base = '/_src'
    
    setup_paths: ->
      @ensure_config()
      @paths = Paths.generate()

    setup_urls: ->
      @ensure_config()
      @urls = Urls.generate()

    # FIXME: plugins not implemented    
    setup_plugins: ->
      @ensure_paths()
      #plugins = Dir[File.join(self.paths.plugins, "**/*.rb")]
      #plugins.each {|f| require f } unless plugins.empty?
    
    ensure_setup: ->
      return if @config and @paths and @urls
      throw 'Ruhoh has not been fully setup. Please call: Ruhoh.setup'
    
    ensure_config: ->
      return if @config
      throw 'Ruhoh has not setup config. Please call: Ruhoh.setup'

    ensure_paths: ->
      return if @config and @paths
      throw 'Ruhoh has not setup paths. Please call: Ruhoh.setup'
    
    ensure_urls: ->
      return if @config and @urls
      throw 'Ruhoh has not setup urls. Please call: Ruhoh.setup + Ruhoh.setup_urls' 
  }

  @Ruhoh
  