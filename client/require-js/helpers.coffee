define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
  "handlebars"
], ($, _, Backbone, Log, Handlebars) ->
  
  # Internal: Register debug helper
  #  debug the passed in data-structure, log to console and output JSON.
  #
  # data - Required [Object] The object to debug.
  #
  # Examples
  #
  #   {{ debug [Object] }}
  #
  # Returns: [String] - JSON string of data.
  Handlebars.registerHelper "debug", (data) ->
    console.log "debug:"
    console.log data
    JSON.stringify data
  
  # Internal: Register analytics helper
  #  Output analytics code as defined by the configuration settings.
  #
  # Examples
  #
  #   {{{ analytics }}}
  #
  # Returns: [String] - The parsed analytics template.
  Handlebars.registerHelper "analytics", ->
    try
      provider = @config.JB.analytics.provider
    catch e
      Log.configError "<br>In order to use {{{ analytics }}} " + "<br>an analytics provider must be specified at: \"site.JB.analytics.provider\""
    (if (@config.production) then Handlebars.compile(Handlebars.partials["analytics." + provider])(this) else "<p class=\"development-notice\" style=\"background:lightblue\">" + provider + " Loaded!</p>")
  
  # Internal: Register comments helper
  #  Output comments code as defined by the configuration settings.
  #
  # Examples
  #
  #   {{{ comments }}}
  #
  # Returns: [String] - The parsed comments template.
  Handlebars.registerHelper "comments", ->
    try
      provider = @config.JB.comments.provider
    catch e
      Log.configError "<br>In order to use {{{ comments }}}} " + "<br>a comments provider must be specified at: \"site.JB.comments.provider\""
    (if (@config.production) then Handlebars.compile(Handlebars.partials["comments." + provider])(this) else "<p class=\"development-notice\" style=\"background:orange\">" + provider + " Loaded!</p>")
  
  # Internal: Register pages_list helper
  # Iterate through a list of pages.
  # TODO: setting any variables in the pages dictionary will alter the dictionary.
  #   Consider deep-cloning each page object.
  #   It works now because the dictionary is renewed on every preview generation.
  #
  # context - Optional [Array]
  #   Pass an array of page ids (page.id)
  #   The ids are expanded into objects from the page dictionary.
  #   If there is no context, we assume the pages dictionary.
  #   TODO: Log unfound pages.
  #
  # Examples
  #
  #   {{#pages_list}} ... {{/pages_list}}
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "pages_list", (context, block) ->
    template = (if block then block.fn else context.fn)
    pages = []
    if _.isArray(context)
      _.each context, ((id) ->
        pages.push @pages[id]  if @pages[id]
      ), this
    else
      pages = @pages
    cache = ""
    _.each pages, ((page) ->
      page.isActivePage = true  if @page.id.replace(/^\//, "") is page.id.replace(/^\//, "")
      cache += template(page)
    ), this
    new Handlebars.SafeString(cache)
  
  # Internal: Register posts_list helper
  # Iterate through a list of ordered posts.
  # Default order is reverse chronological.
  #
  # context - Optional [Array]
  #   Pass an array of post ids (post.id)
  #   The ids are expanded into objects from the post dictionary.
  #   If there is no context, we assume the ordered post array from posts dictionary..
  #
  # Examples
  #
  #   {{#posts_list}} ... {{/posts_list}}
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "posts_list", (context, block) ->
    template = (if block then block.fn else context.fn)
    posts = _.map(((if _.isArray(context) then context else @posts.chronological)), (id) ->
      @posts.dictionary[id]
    , this)
    cache = ""
    _.each posts, ((posts) ->
      cache += template(posts)
    ), this
    new Handlebars.SafeString(cache)
  
  # Internal: Register tags_list helper.
  # Iterate through a list of tags.
  #
  # context - Optional [Array] Pass an array of tag names.
  #   The names are expanded into objects from the tags dictionary.
  #   If there is no context, we assume all tags in the dictionary.
  #
  # Examples
  #
  #   {{#tags_list}} ... {{/tags_list}}
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "tags_list", (context, block) ->
    template = (if block then block.fn else context.fn)
    tags = (if _.isArray(context) then _.map(context, (name) ->
      @posts.tags[name]
    , this) else @posts.tags)
    cache = ""
    _.each tags, ((tag) ->
      cache += template(tag)
    ), this
    new Handlebars.SafeString(cache)
  
  # Internal: Register categories_list helper.
  # Iterate through a list of categories.
  #
  # context - Optional [Array] Pass an array of category names.
  #   The names are expanded into objects from the categories dictionary.
  #   If there is no context, we assume all categories in the dictionary.
  #
  # Examples
  #
  #   {{#categories_list}} ... {{/categories_list}}
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "categories_list", (context, block) ->
    template = (if block then block.fn else context.fn)
    categories = (if _.isArray(context) then _.map(context, (name) ->
      @posts.categories[name]
    , this) else @posts.categories)
    cache = ""
    _.each categories, ((cat) ->
      cache += template(cat)
    ), this
    new Handlebars.SafeString(cache)
  
  # Internal: Register posts_collate block helper
  # Collate posts by year and month descending.
  #
  # Examples
  #
  #   {{#posts_collate }} ... {{/posts_collate}}
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "posts_collate", (block) ->
    template = block.fn
    cache = ""
    _.each @posts.collated, ((data) ->
      cache += template(data)
    ), this
    new Handlebars.SafeString(cache)
  
  # Internal: Register next helper
  # Returns the next (newer) post relative to the calling page.
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "post_next", (context, block) ->
    template = (if block then block.fn else context.fn)
    position = @posts.chronological.indexOf(@page.id)
    first = _.first(@posts.chronological)
    cache = (if (position is -1 or @page.id is first) then template.inverse({}) else template(@posts.dictionary[@posts.chronological[position - 1]]))
    new Handlebars.SafeString(cache)
  
  # Internal: Register previous helper
  # Returns the previous (older) post relative to the calling page.
  #
  # Returns: [String] - The parsed block content.
  Handlebars.registerHelper "post_previous", (context, block) ->
    template = (if block then block.fn else context.fn)
    position = @posts.chronological.indexOf(@page.id)
    last = _.last(@posts.chronological)
    cache = (if (position is -1 or @page.id is last) then template.inverse({}) else template(@posts.dictionary[@posts.chronological[position + 1]]))
    new Handlebars.SafeString(cache)

  Handlebars
