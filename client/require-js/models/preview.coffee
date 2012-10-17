define [
  "jquery"
  "underscore"
  "backbone"
  
  "cs!dictionaries/pages"
  "cs!dictionaries/posts"
  
  "cs!models/config"
  "cs!models/page"
  "cs!models/layout"
  "cs!models/payload"
  "cs!models/partial"
  
  "cs!collections/partials"
  
  "cs!utils/log"
  "mustache"
  "cs!helpers"
], ($, _, Backbone,
  PagesDictionary, PostsDictionary,
  Config, Page, Layout, Payload, Partial,
  Partials,
  Log, Mustache) ->
    
  TemplateEngine = "Mustache"
  ContentRegex = /\{\{\s*content\s*\}\}/i
  
  # Preview object builds a preview of a given page/post
  #
  # There is only ever one preview at any given time.
  # page/posts exist as data-structures only.
  # Aggrregate data-structures can be built from those objects.
  #
  # However for the purpose of the client, the preview
  # object is what renders what you see in the browser.
  Backbone.Model.extend
    master: Layout
    sub: Layout
    page: Page
    payload: Payload
    initialize: (attrs, config) ->
      @config = config
      @page = new Page
      @page.sub = new Layout
      @page.master = new Layout
      @payload = new Payload
      @pagesDictionary = new PagesDictionary
      @postsDictionary = new PostsDictionary
      @partials = new Partials
      
      # Set pointers to a single Config.
      @page.config = @config
      @page.sub.config = @config
      @page.master.config = @config
      @payload.config = @config
      @partials.config = @config
      @pagesDictionary.config = @config
      @postsDictionary.config = @config

      @page.bind "change:id", (->
        @generate()
      ), this

    generate: ->
      that = this
      $.when(@page.generate(), @partials.generate(), @pagesDictionary.generate(), @postsDictionary.generate()).done(->
        that.buildPayload()
        that.process()
      ).fail (jqxhr) ->
        Log.loadError this, jqxhr
    
    # Build the payload.
    buildPayload: ->
      @payload.set
        config: @config.attributes
        page: @page.attributes
        pages: @pagesDictionary.attributes
        posts: @postsDictionary.attributes
        ASSET_PATH: @config.getThemePath()
        HOME_PATH: "/"
        BASE_PATH: ""

    process: ->
      output = @page.sub.get("content").replace(ContentRegex, @page.get("content"))
      
      # An undefined master means the page/post layouts is only one deep.
      # This means it expects to load directly into a master template.
      output = @page.master.get("content").replace(ContentRegex, output)  if @page.master.id
      this[TemplateEngine] output
    
    # Public: Process content, sub+master templates then render the result.
    #
    # TODO: Include YAML Front Matter from the templates.
    # Returns: Nothing. The finished preview is rendered in the Browser.
    Handlebars: (output) ->
      template = Handlebars.compile(output)
      $(document).html template(@payload.attributes)
    
    # Public: Process content, sub+master templates then render the result.
    #
    # TODO: Include YAML Front Matter from the templates.
    # Returns: Nothing. The finished preview is rendered in the Browser.
    Mustache: (output) ->
      $("body").html Mustache.render(output, @payload.attributes, @partials.toHash())
