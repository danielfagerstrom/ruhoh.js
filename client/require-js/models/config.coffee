define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
], ($, _, Backbone, Log) ->
  
  # Config Model
  Backbone.Model.extend
    initialize: (attrs) ->
      @set
        time: new Date().toString()
        basePath: (attrs.basePath or "/")
        postsDirectory: "posts"
        pagesDirectory: "pages"
      @buildBasePath()
      @bind "change:basePath", @buildBasePath, this

    generate: ->
      @fetch
        dataType: "html"
        cache: false

    url: ->
      "/" + @fileJoin(@get("site_source"), "/config.yml")

    parse: (response) ->
      @set jsyaml.load(response)
      @validateConfig()
      @attributes
    
    # Ensure we have the required configuration settings.
    validateConfig: ->
      Log.configError "theme is not set. <br> ex: theme : my-theme"  unless _.isString(@get("theme"))

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
      @getPath @get("site_source"), "themes", @get("theme"), path

    getDataPath: (path) ->
      @getPath @get("site_source"), path
    
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
