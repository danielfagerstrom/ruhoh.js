define [
  "jquery"
  "underscore"
  "backbone"
  "cs!utils/log"
  "handlebars"
  "cs!models/partial"
], ($, _, Backbone, Log, Handlebars, Partial) ->
  
  # Partial Colletion
  Backbone.Collection.extend
    model: Partial
    
    # Framework partials only.
    # The user should not alter these partials, 
    # instead just create their own.
    # [path, name]
    FrameworkPartials: [
      ["pages_list", "pages_list"]
      ["posts_list", "posts_list"]
      ["tags_list", "tags_list"]
      ["categories_list", "categories_list"]
      ["posts_collate", "posts_collate"]
      
      ["analytics-providers/google", "analytics.google"]
      ["analytics-providers/getclicky", "analytics.getclicky"]
      
      ["comments-providers/disqus", "comments.disqus"]
      ["comments-providers/intensedebate", "comments.intensedebate"]
      ["comments-providers/livefyre", "comments.livefyre"]
      ["comments-providers/facebook", "comments.facebook"]
    ]
    initialize: (attrs) ->
      _.each @FrameworkPartials, ((partial) ->
        @add
          id: partial[1]
          path: partial[0]
      ), this

    
    # Generate each partial in this collection.
    # 
    # Returns: $.Deferred resolved only after all partials are loaded.
    generate: ->
      dfds = @map((partial) ->
        partial.config = @config
        partial.generate()
      , this)
      $.when.apply this, dfds

    toHash: ->
      hash = {}
      _.each @toJSON(), (p) ->
        hash[p.id] = p.content
      hash
