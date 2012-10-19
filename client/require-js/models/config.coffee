define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
], ($, _, Backbone, Log) ->

  Ruhoh = @Ruhoh
  
  # Config Model
  Backbone.Model.extend
    initialize: (attrs) ->
      @set
        time: new Date().toString()
        basePath: (attrs?.basePath or "/")
        postsDirectory: "posts"
        pagesDirectory: "pages"
      @buildBasePath()
      @bind "change:basePath", @buildBasePath, this

    generate: ->
      @fetch dataType: "html", cache: false

    url: ->
      "/" + @fileJoin(Ruhoh.base,  Ruhoh.names.config_data)

    parse: (response) ->
      site_config = jsyaml.load(response)
      @validateConfig(site_config)
      @set @setDefaults(site_config)
      @attributes

    setDefaults: (site_config) ->
      theme = if site_config.theme then site_config.theme.replace(/\s/, '') else ''
      
      config = {}
      config.theme = theme

      config.production_url = site_config.production_url
      
      config.env = site_config.env || null

      config.base_path = '/'
      if site_config.base_path
        config.base_path = site_config.base_path
        config.base_path += "/" unless config.base_path[config.base_path.length - 1] == '/'
      
      config.rss_limit = site_config.rss?.limit ? 20

      config.posts_permalink = site_config.posts?.permalink ? "/:categories/:year/:month/:day/:title.html"
      config.posts_layout = site_config.posts?.layout ? 'post'
      excluded_posts = site_config.posts?.exclude ? []
      config.posts_exclude = (new Regexp node for node in excluded_posts)
      
      config.pages_permalink = site_config.pages?.permalink
      config.pages_layout = site_config.pages?.layout ? 'page'
      excluded_pages = site_config.pages?.exclude ? []
      config.pages_exclude = (new Regexp node for node in excluded_pages)
      
      config
    
    # Ensure we have the required configuration settings.
    validateConfig: (site_config) ->
      Log.configError "theme is not set. <br> ex: theme : my-theme"  unless _.isString(site_config.theme)

    # Internal: Get a normalized, absolute path for the App Session.
    # Normalizes submitted paths into a well-formed url.
    # Similar to File.join(a, b, c) in ruby.
    #
    # arguments - (Optional) Takes a variable number of arguments
    #  representing a path to a particular asset.
    #
    # Returns: String - Normalized absolute URL path to asset.
    getPath: ->
      return @get("basePath").join("/")  if arguments.length is 0
      @get("basePath").concat(_.compact(Array::slice.call(arguments).join("/").split("/"))).join "/"
    
    # Like ruby B)
    fileJoin: ->
      return ""  if arguments.length is 0
      _.compact(Array::slice.call(arguments).join("/").split("/")).join "/"
    
    # Internal : Builds the absolute URL path to assets relative to enabled theme.
    #
    # path - (Optional) String of a path to an asset.
    # Returns: String - Normalized absolute URL paath to theme assets.
    getThemePath: (path) ->
      @getPath Ruhoh.base, "themes", @get("theme"), path

    getDataPath: (path) ->
      @getPath Ruhoh.base, path
    
    # Internal: Normalizes a root domain into a well-formed URL.
    #
    # root - (Required) String the root url of the webpage the app loads within.
    # Returns: String - Normalized absolute URL root.
    buildBasePath: ->
      nodes = @get("basePath").split("/")
      nodes.pop()  if ["", "index.html", "index.md"].indexOf(_.last(nodes)) isnt -1
      @set "basePath", nodes
    
    # Thanks: Amr ElGarhy - http://stackoverflow.com/a/3388227/101940
    getQueryParam: (variable) ->
      query = window.location.search.substring(1)
      vars = query.split("&")
      i = 0

      while i < vars.length
        pair = vars[i].split("=")
        return pair[1]  if pair[0] is variable
        i++
      null
