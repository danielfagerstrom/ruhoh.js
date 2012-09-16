define([
  'jquery',
  'underscore',
], function($, _){

  return {

    // parse the mustache expression's name
    parseContext : function(tagName){
      return tagName.split('?')[0] || null;
    },

    // Query based on helper name
    // Helpers must start with "?"
    // If we can't find anything it's important to return undefined.
    query : function(name, context, stack){
      var helper = name.split('?')[1];
      if(helper && typeof this[helper] === 'function')
        return this[helper](context, stack)
    },

    to_pages : function(context, stack){
      var pages = [];
      if ( _.isArray(context) )
        _.each(context, function(id){
          if(stack.pages[id]) pages.push(stack.pages[id])
        })
      else pages = stack.pages;

      return _.map(pages, function(page){
        if(stack.page.id === page.id)
          page.isActivePage = true;
        return page
      })
    },

    to_tags : function(context, stack){
      return _.isArray(context)
        ?  _.map(context, function(name){
             if(stack.posts.tags[name])
              return stack.posts.tags[name]
           })
        :  _.map(stack.posts.tags, function(tag){
             return tag
           })
    },

    to_posts : function(context, stack){
      return _.map(
          _.isArray(context)
            ? context
            : stack.posts.chronological,
          function(id) {
            if(stack.posts.dictionary[id])
              return stack.posts.dictionary[id]
          }
        )
    },

    to_categories : function(context, stack){
      return _.isArray(context)
        ?  _.map(context, function(name){
             if(stack.posts.categories[name])
              return stack.posts.categories[name]
           })
        :  _.map(stack.posts.categories, function(cat){
             return cat
           })
    },

    // Probably not going to use this since its simple enough to
    // call the data structure directly.
    posts_collate : function(context, stack){
      return stack.posts.collated;
    }

  }

})
