define([
  'jquery',
  'underscore',
  'backbone',
  'utils/log',
  'handlebars',
], function($, _, Backbone, Log, Handlebars){

  // Internal: Register debug helper
  //  debug the passed in data-structure, log to console and output JSON.
  //
  // data - Required [Object] The object to debug.
  //
  // Examples
  //
  //   {{ debug [Object] }}
  //
  // Returns: [String] - JSON string of data.
  Handlebars.registerHelper('debug', function(data) {
    console.log("debug:");
    console.log(data);
    return JSON.stringify(data);
  });

  // Internal: Register analytics helper
  //  Output analytics code as defined by the configuration settings.
  //
  // Examples
  //
  //   {{{ analytics }}}
  //
  // Returns: [String] - The parsed analytics template.
  Handlebars.registerHelper('analytics', function() {
    try{
      var provider = this.config.JB.analytics.provider;
    } catch(e) {
      Log.configError(
        '<br>In order to use {{{ analytics }}} ' +
        '<br>an analytics provider must be specified at: "site.JB.analytics.provider"'
      )
    }
    return (this.config.production)
      ? Handlebars.compile(Handlebars.partials['analytics.'+provider])(this)
      : '<p class="development-notice" style="background:lightblue">'+ provider +' Loaded!</p>';
  });

  // Internal: Register comments helper
  //  Output comments code as defined by the configuration settings.
  //
  // Examples
  //
  //   {{{ comments }}}
  //
  // Returns: [String] - The parsed comments template.
  Handlebars.registerHelper('comments', function() {
    try{
      var provider = this.config.JB.comments.provider;
    } catch(e) {
      Log.configError(
        '<br>In order to use {{{ comments }}}} ' +
        '<br>a comments provider must be specified at: "site.JB.comments.provider"'
      )
    }

    return (this.config.production)
      ? Handlebars.compile(Handlebars.partials['comments.'+provider])(this)
      : '<p class="development-notice" style="background:orange">'+ provider +' Loaded!</p>';
  });

  // Internal: Register pages_list helper
  // Iterate through a list of pages.
  // TODO: setting any variables in the pages dictionary will alter the dictionary.
  //   Consider deep-cloning each page object.
  //   It works now because the dictionary is renewed on every preview generation.
  //
  // context - Optional [Array]
  //   Pass an array of page ids (page.id)
  //   The ids are expanded into objects from the page dictionary.
  //   If there is no context, we assume the pages dictionary.
  //   TODO: Log unfound pages.
  //
  // Examples
  //
  //   {{#pages_list}} ... {{/pages_list}}
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('pages_list', function(context, block) {
    var template = block ? block.fn : context.fn;

    var pages = [];
    if ( _.isArray(context) )
      _.each(context, function(id){
        if(this.pages[id]) pages.push(this.pages[id])
      }, this)
    else pages = this.pages;

    var cache = '';
    _.each(pages, function(page){
      if(this.page.id.replace(/^\//,'') === page.id.replace(/^\//,'')) page.isActivePage = true;
      cache += template(page);
    }, this);

    return new Handlebars.SafeString(cache);
  });

  // Internal: Register posts_list helper
  // Iterate through a list of ordered posts.
  // Default order is reverse chronological.
  //
  // context - Optional [Array]
  //   Pass an array of post ids (post.id)
  //   The ids are expanded into objects from the post dictionary.
  //   If there is no context, we assume the ordered post array from posts dictionary..
  //
  // Examples
  //
  //   {{#posts_list}} ... {{/posts_list}}
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('posts_list', function(context, block) {
    var template = block ? block.fn : context.fn;
    var posts = _.map(
      ( _.isArray(context) ? context : this.posts.chronological ),
      function(id){ return this.posts.dictionary[id] },
      this
    );

    var cache = '';
    _.each(posts, function(posts){
      cache += template(posts);
    }, this);

    return new Handlebars.SafeString(cache);
  });

  // Internal: Register tags_list helper.
  // Iterate through a list of tags.
  //
  // context - Optional [Array] Pass an array of tag names.
  //   The names are expanded into objects from the tags dictionary.
  //   If there is no context, we assume all tags in the dictionary.
  //
  // Examples
  //
  //   {{#tags_list}} ... {{/tags_list}}
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('tags_list', function(context, block) {
    var template = block ? block.fn : context.fn;
    var tags = _.isArray(context)
      ? _.map( context, function(name){ return this.posts.tags[name] }, this)
      : this.posts.tags;

    var cache = '';
    _.each(tags, function(tag){
      cache += template(tag);
    }, this);

    return new Handlebars.SafeString(cache);
  });

  // Internal: Register categories_list helper.
  // Iterate through a list of categories.
  //
  // context - Optional [Array] Pass an array of category names.
  //   The names are expanded into objects from the categories dictionary.
  //   If there is no context, we assume all categories in the dictionary.
  //
  // Examples
  //
  //   {{#categories_list}} ... {{/categories_list}}
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('categories_list', function(context, block) {
    var template = block ? block.fn : context.fn;
    var categories = _.isArray(context)
      ? _.map( context, function(name){ return this.posts.categories[name] }, this)
      : this.posts.categories;

    var cache = '';
    _.each(categories, function(cat){
      cache += template(cat);
    }, this);

    return new Handlebars.SafeString(cache);
  });

  // Internal: Register posts_collate block helper
  // Collate posts by year and month descending.
  //
  // Examples
  //
  //   {{#posts_collate }} ... {{/posts_collate}}
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('posts_collate', function(block) {
    var template = block.fn;
    var cache = '';
    _.each(this.posts.collated, function(data){
      cache += template(data);
    }, this);

    return new Handlebars.SafeString(cache);
  });

  // Internal: Register next helper
  // Returns the next (newer) post relative to the calling page.
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('post_next', function(context, block) {
    var template = block ? block.fn : context.fn;
    var position = this.posts.chronological.indexOf(this.page.id);
    var first = _.first(this.posts.chronological);
    var cache = (position === -1 || this.page.id === first)
      ? template.inverse({})
      : template( this.posts.dictionary[ this.posts.chronological[position-1] ] );
    return new Handlebars.SafeString(cache);
  });

  // Internal: Register previous helper
  // Returns the previous (older) post relative to the calling page.
  //
  // Returns: [String] - The parsed block content.
  Handlebars.registerHelper('post_previous', function(context, block) {
    var template = block ? block.fn : context.fn;
    var position = this.posts.chronological.indexOf(this.page.id);
    var last = _.last(this.posts.chronological);
    var cache = (position === -1 || this.page.id === last)
      ? template.inverse({})
      : template( this.posts.dictionary[ this.posts.chronological[position+1] ] );
    return new Handlebars.SafeString(cache);
  });

  return Handlebars;
});